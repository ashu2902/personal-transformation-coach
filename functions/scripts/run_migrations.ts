import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp({
    projectId: "aura-coach-ashu-7",
    storageBucket: "aura-coach-ashu-7.firebasestorage.app",
  });
}

const db = admin.firestore();
const storage = admin.storage();
const bucket = storage.bucket("gs://aura-coach-ashu-7.firebasestorage.app");

async function runMigrations() {
  console.log("🚀 Starting AURA Database Migration...");

  try {
    const usersSnap = await db.collection("users").get();
    console.log(`Found ${usersSnap.size} user(s) to migrate.`);

    for (const userDoc of usersSnap.docs) {
      const uid = userDoc.id;
      const data = userDoc.data();
      console.log(`\n--- Migrating User: ${uid} (${data.name || "Unnamed"}) ---`);

      const batch = db.batch();
      let userUpdated = false;
      const userUpdates: any = {};

      // 1. Schema Migration: master_context -> memory_drawer
      if (data.master_context || !data.memory_drawer) {
        const mc = data.master_context || {};
        const memoryDrawer = {
          schedule_constraints: mc.scheduleConstraints || data.lifestyleNotes || [],
          equipment_details: mc.equipmentNotes || (data.equipmentList ? data.equipmentList.map((e: any) => (typeof e === "string" ? e : e.name)).join(", ") : "Bodyweight"),
          dietary_nuances: mc.dietaryNuances || data.dietaryPreference || "None",
          mobility_limitations: mc.injuries || data.activeInjuries || [],
          physique_aspirations: mc.aspirations || data.targetPhysique || "",
          fasting_protocol: mc.fastingProtocol || "",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        userUpdates.memory_drawer = memoryDrawer;
        userUpdates.master_context = admin.firestore.FieldValue.delete();
        userUpdated = true;
        console.log(`  ✓ Converted master_context -> memory_drawer`);
      }

      // 2. Canonical Equipment List structure verification
      if (Array.isArray(data.equipmentList)) {
        const normalizedEquipment = data.equipmentList.map((item: any) => {
          if (typeof item === "string") {
            return {
              name: item,
              category: "other",
            };
          }
          return item;
        });
        userUpdates.equipmentList = normalizedEquipment;
        userUpdated = true;
      }

      // 3. Weekly Plan Invalidation
      userUpdates.needsWeeklyPlanRegen = true;
      userUpdated = true;
      console.log(`  ✓ Flagged weekly plan for AI regeneration`);

      if (userUpdated) {
        userUpdates.migratedAt = admin.firestore.FieldValue.serverTimestamp();
        batch.update(userDoc.ref, userUpdates);
      }

      await batch.commit();

      // 4. Migrate Chat Messages with base64 image strings to Cloud Storage URLs
      const chatsSnap = await db.collection("users").doc(uid).collection("chats").get();
      for (const chatDoc of chatsSnap.docs) {
        // Also query the messages subcollection for each chat
        const msgsSnap = await chatDoc.ref.collection("messages").get();
        for (const msgDoc of msgsSnap.docs) {
          const msgData = msgDoc.data();
          if (msgData.imageBytes || msgData.imageBase64) {
            const rawBase64 = msgData.imageBase64 || msgData.imageBytes;
            if (typeof rawBase64 === "string" && rawBase64.length > 100) {
              try {
                const buffer = Buffer.from(rawBase64.replace(/^data:image\/\w+;base64,/, ""), "base64");
                const filename = `chat_images/${uid}/${msgDoc.id}.jpg`;
                const file = bucket.file(filename);
                await file.save(buffer, {
                  metadata: { contentType: "image/jpeg" },
                });
                await file.makePublic().catch(() => {});
                const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filename}`;

                await msgDoc.ref.update({
                  imageUrl: publicUrl,
                  imageBytes: admin.firestore.FieldValue.delete(),
                  imageBase64: admin.firestore.FieldValue.delete(),
                });
                console.log(`  ✓ Migrated legacy base64 image in message ${msgDoc.id} -> Storage URL`);
              } catch (imgErr) {
                console.warn(`  ⚠️ Failed migrating image for message ${msgDoc.id}:`, imgErr);
              }
            }
          }
        }
      }
    }

    console.log("\n✅ AURA Database Migration completed successfully!");
  } catch (err) {
    console.error("❌ Migration failed with error:", err);
  }
}

if (require.main === module) {
  runMigrations()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error(err);
      process.exit(1);
    });
}
