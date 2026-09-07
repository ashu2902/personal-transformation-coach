import * as admin from "firebase-admin";
import { getFirestore } from "firebase-admin/firestore";

if (!admin.apps.length) {
  admin.initializeApp({
    projectId: "aura-coach-ashu-7",
    storageBucket: "aura-coach-ashu-7.firebasestorage.app",
  });
}

// Enterprise database named "default" (Source)
const sourceDb = getFirestore("default");

// Standard database named "(default)" (Target)
const targetDb = getFirestore("(default)");

const storage = admin.storage();
const bucket = storage.bucket("gs://aura-coach-ashu-7.firebasestorage.app");

export interface MigrationSummary {
  usersMigrated: number;
  subcollectionsMigrated: number;
  documentsMigrated: number;
  imagesMigrated: number;
  errors: string[];
}

/**
 * Recursively copies all subcollections from a source document reference to a target document reference.
 */
async function copySubcollections(
  sourceDocRef: admin.firestore.DocumentReference,
  targetDocRef: admin.firestore.DocumentReference,
  uid: string,
  summary: MigrationSummary,
  isDryRun: boolean
) {
  const subcollections = await sourceDocRef.listCollections();
  for (const subcol of subcollections) {
    summary.subcollectionsMigrated++;
    const snap = await subcol.get();
    console.log(`    ↳ Subcollection '${subcol.id}' has ${snap.size} document(s)`);

    for (const doc of snap.docs) {
      let docData = doc.data();
      summary.documentsMigrated++;

      // Handle chat message base64 images -> Cloud Storage URLs
      if (subcol.id === "messages" && (docData.imageBytes || docData.imageBase64)) {
        const rawBase64 = docData.imageBase64 || docData.imageBytes;
        if (typeof rawBase64 === "string" && rawBase64.length > 100) {
          try {
            if (!isDryRun) {
              const buffer = Buffer.from(rawBase64.replace(/^data:image\/\w+;base64,/, ""), "base64");
              const filename = `chat_images/${uid}/${doc.id}.jpg`;
              const file = bucket.file(filename);
              await file.save(buffer, {
                metadata: { contentType: "image/jpeg" },
              });
              await file.makePublic().catch(() => {});
              const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filename}`;

              docData = {
                ...docData,
                imageUrl: publicUrl,
              };
              delete docData.imageBytes;
              delete docData.imageBase64;
              summary.imagesMigrated++;
              console.log(`      ✓ Migrated base64 image in message ${doc.id} -> ${publicUrl}`);
            } else {
              console.log(`      [DRY-RUN] Would migrate base64 image in message ${doc.id}`);
            }
          } catch (imgErr: any) {
            console.warn(`      ⚠️ Failed migrating image for message ${doc.id}:`, imgErr.message);
            summary.errors.push(`Image migration failed for ${uid}/${doc.id}: ${imgErr.message}`);
          }
        }
      }

      const targetDocChildRef = targetDocRef.collection(subcol.id).doc(doc.id);
      if (!isDryRun) {
        await targetDocChildRef.set(docData, { merge: true });
      }

      // Recurse into nested subcollections (e.g. chats/default_chat/messages)
      await copySubcollections(doc.ref, targetDocChildRef, uid, summary, isDryRun);
    }
  }
}

export async function runEnterpriseToStandardMigration(isDryRun: boolean = false): Promise<MigrationSummary> {
  const modeLabel = isDryRun ? "[DRY-RUN]" : "[LIVE]";
  console.log(`\n🚀 ${modeLabel} Starting AURA Migration: Enterprise ("default") -> Standard ("(default)")...`);

  const summary: MigrationSummary = {
    usersMigrated: 0,
    subcollectionsMigrated: 0,
    documentsMigrated: 0,
    imagesMigrated: 0,
    errors: [],
  };

  try {
    const usersSnap = await sourceDb.collection("users").get();
    console.log(`Found ${usersSnap.size} user(s) in Enterprise 'default' database.`);

    for (const userDoc of usersSnap.docs) {
      const uid = userDoc.id;
      const data = userDoc.data();
      const userName = data.name || "Unnamed Athlete";
      console.log(`\n--- Migrating User: ${uid} (${userName}) ---`);

      // 1. Schema Migration: master_context -> memory_drawer
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

      // 2. Canonical Equipment List structure verification
      let normalizedEquipment = data.equipmentList;
      if (Array.isArray(data.equipmentList)) {
        normalizedEquipment = data.equipmentList.map((item: any) => {
          if (typeof item === "string") {
            return {
              name: item,
              category: "other",
            };
          }
          return item;
        });
      }

      const updatedUserData: any = {
        ...data,
        memory_drawer: memoryDrawer,
        equipmentList: normalizedEquipment,
        needsWeeklyPlanRegen: true,
        migratedAt: admin.firestore.FieldValue.serverTimestamp(),
        migratedFrom: "enterprise_default",
      };
      delete updatedUserData.master_context;

      if (!isDryRun) {
        const targetUserRef = targetDb.collection("users").doc(uid);
        await targetUserRef.set(updatedUserData, { merge: true });
        console.log(`  ✓ Written canonical user profile to target Standard database`);

        // 3. Migrate all subcollections recursively
        await copySubcollections(userDoc.ref, targetUserRef, uid, summary, isDryRun);
      } else {
        console.log(`  [DRY-RUN] Would write profile for ${uid}`);
        await copySubcollections(userDoc.ref, targetDb.collection("users").doc(uid), uid, summary, true);
      }

      summary.usersMigrated++;
    }

    console.log(`\n======================================================`);
    console.log(`✅ ${modeLabel} AURA Migration Complete!`);
    console.log(`Users Migrated:         ${summary.usersMigrated}`);
    console.log(`Subcollections Scanned: ${summary.subcollectionsMigrated}`);
    console.log(`Documents Copied:       ${summary.documentsMigrated}`);
    console.log(`Images Converted:       ${summary.imagesMigrated}`);
    console.log(`Errors:                 ${summary.errors.length}`);
    console.log(`======================================================\n`);
  } catch (err: any) {
    console.error(`❌ Migration failed with error:`, err);
    summary.errors.push(err.message || String(err));
  }

  return summary;
}

if (require.main === module) {
  const isDryRun = process.argv.includes("--dry-run");
  runEnterpriseToStandardMigration(isDryRun)
    .then(() => process.exit(0))
    .catch((err) => {
      console.error(err);
      process.exit(1);
    });
}
