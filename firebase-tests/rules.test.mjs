// Security-rules tests for MY AIM (Firestore + Storage), run in the emulator:
//   cd firebase-tests && npm install && npm test
import { test, before, after, beforeEach } from 'node:test';
import { readFileSync } from 'node:fs';
import {
  initializeTestEnvironment, assertSucceeds, assertFails,
} from '@firebase/rules-unit-testing';
import {
  doc, getDoc, setDoc, updateDoc, deleteDoc, collection, query, where, getDocs,
  serverTimestamp, increment,
} from 'firebase/firestore';
import { ref, uploadBytes, getBytes } from 'firebase/storage';

const TRAINEE = 'trainee1', ACADEMY = 'academy1', STRANGER = 'stranger1';
let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-myaim',
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'), host: '127.0.0.1', port: 8080 },
    storage: { rules: readFileSync(new URL('../storage.rules', import.meta.url), 'utf8'), host: '127.0.0.1', port: 9199 },
  });
});
after(async () => { await env.cleanup(); });
beforeEach(async () => { await env.clearFirestore(); await env.clearStorage(); });

const db = (uid) => (uid ? env.authenticatedContext(uid) : env.unauthenticatedContext()).firestore();
const st = (uid) => (uid ? env.authenticatedContext(uid) : env.unauthenticatedContext()).storage();

/** Seeds docs bypassing rules. */
async function seed(fn) {
  await env.withSecurityRulesDisabled(async (ctx) => fn(ctx.firestore()));
}

const service = (extra = {}) => ({
  title: 'دورة', summary: 's', category: 'sports', providerName: 'أكاديمية',
  providerId: 'x', isVerified: false, rating: 0, reviewsCount: 0, startingPrice: 100,
  location: { city: 'الرياض', latitude: 24.7, longitude: 46.6 }, createdAt: serverTimestamp(), ...extra,
});
const convo = { userId: TRAINEE, providerUid: ACADEMY, name: 'أكاديمية', category: 'sports',
                unread: 0, academyUnread: 0, traineeName: 'أحمد' };

// ---------- services ----------
test('services: anyone can read the catalog', async () => {
  await seed((d) => setDoc(doc(d, 'services/s1'), service()));
  await assertSucceeds(getDoc(doc(db(null), 'services/s1')));
});

test('services: seeding an unowned catalog item is allowed', async () => {
  await assertSucceeds(setDoc(doc(db(TRAINEE), 'services/seed1'), service()));
});

test('services: academy publishes a course it owns', async () => {
  await assertSucceeds(setDoc(doc(db(ACADEMY), 'services/c1'), service({ ownerUid: ACADEMY })));
});

test('services: cannot publish under someone else\'s account', async () => {
  await assertFails(setDoc(doc(db(STRANGER), 'services/c1'), service({ ownerUid: ACADEMY })));
});

test('services: only the owner can update/delete its course', async () => {
  await seed((d) => setDoc(doc(d, 'services/c1'), service({ ownerUid: ACADEMY })));
  await assertFails(updateDoc(doc(db(STRANGER), 'services/c1'), { startingPrice: 1 }));
  await assertFails(deleteDoc(doc(db(STRANGER), 'services/c1')));
  await assertSucceeds(setDoc(doc(db(ACADEMY), 'services/c1'), service({ ownerUid: ACADEMY, startingPrice: 90 }), { merge: true }));
  await assertSucceeds(deleteDoc(doc(db(ACADEMY), 'services/c1')));
});

test('services: nobody can edit the unowned sample catalog', async () => {
  await seed((d) => setDoc(doc(d, 'services/seed1'), service()));
  await assertFails(updateDoc(doc(db(TRAINEE), 'services/seed1'), { startingPrice: 1 }));
});

// ---------- bookings / goals ----------
for (const col of ['bookings', 'goals']) {
  test(`${col}: owner-only`, async () => {
    await assertSucceeds(setDoc(doc(db(TRAINEE), `${col}/b1`), { userId: TRAINEE }));
    await assertFails(setDoc(doc(db(TRAINEE), `${col}/b2`), { userId: STRANGER }));
    await assertSucceeds(getDoc(doc(db(TRAINEE), `${col}/b1`)));
    await assertFails(getDoc(doc(db(STRANGER), `${col}/b1`)));
    await assertSucceeds(getDocs(query(collection(db(TRAINEE), col), where('userId', '==', TRAINEE))));
  });
}

// ---------- providers ----------
test('providers: academy owns its document and subcollections', async () => {
  await assertSucceeds(setDoc(doc(db(ACADEMY), `providers/${ACADEMY}`), { academyName: 'x' }));
  await assertSucceeds(setDoc(doc(db(ACADEMY), `providers/${ACADEMY}/courses/c1`), { title: 't' }));
  await assertFails(getDoc(doc(db(STRANGER), `providers/${ACADEMY}/courses/c1`)));
  await assertFails(setDoc(doc(db(STRANGER), `providers/${ACADEMY}/posts/p1`), { text: 'x' }));
});

// ---------- conversations ----------
test('conversations: trainee opens a thread addressed to an academy', async () => {
  await assertSucceeds(setDoc(doc(db(TRAINEE), 'conversations/t1'), convo, { merge: true }));
  await assertFails(setDoc(doc(db(STRANGER), 'conversations/t2'), convo));
});

test('conversations: both parties read, stranger cannot', async () => {
  await seed((d) => setDoc(doc(d, 'conversations/t1'), convo));
  await assertSucceeds(getDoc(doc(db(TRAINEE), 'conversations/t1')));
  await assertSucceeds(getDoc(doc(db(ACADEMY), 'conversations/t1')));
  await assertFails(getDoc(doc(db(STRANGER), 'conversations/t1')));
});

test('conversations: list queries used by the app are allowed', async () => {
  await seed((d) => setDoc(doc(d, 'conversations/t1'), convo));
  await assertSucceeds(getDocs(query(collection(db(TRAINEE), 'conversations'), where('userId', '==', TRAINEE))));
  await assertSucceeds(getDocs(query(collection(db(ACADEMY), 'conversations'), where('providerUid', '==', ACADEMY))));
  await assertFails(getDocs(query(collection(db(STRANGER), 'conversations'), where('providerUid', '==', ACADEMY))));
});

test('conversations: messages — both parties write/read, stranger cannot', async () => {
  await seed((d) => setDoc(doc(d, 'conversations/t1'), convo));
  const msg = { text: 'مرحبا', fromMe: true, date: new Date() };
  await assertSucceeds(setDoc(doc(db(TRAINEE), 'conversations/t1/messages/m1'), msg));
  await assertSucceeds(setDoc(doc(db(ACADEMY), 'conversations/t1/messages/m2'), { ...msg, fromMe: false }));
  await assertSucceeds(getDocs(collection(db(ACADEMY), 'conversations/t1/messages')));
  await assertFails(getDocs(collection(db(STRANGER), 'conversations/t1/messages')));
  await assertFails(setDoc(doc(db(STRANGER), 'conversations/t1/messages/m3'), msg));
});

test('conversations: counters the app updates are allowed', async () => {
  await seed((d) => setDoc(doc(d, 'conversations/t1'), convo));
  await assertSucceeds(updateDoc(doc(db(TRAINEE), 'conversations/t1'),
    { updatedAt: serverTimestamp(), academyUnread: increment(1) }));
  await assertSucceeds(updateDoc(doc(db(ACADEMY), 'conversations/t1'),
    { updatedAt: serverTimestamp(), unread: increment(1) }));
  await assertSucceeds(updateDoc(doc(db(ACADEMY), 'conversations/t1'), { academyUnread: 0 }));
});

test('conversations: academy cannot rewrite thread ownership', async () => {
  await seed((d) => setDoc(doc(d, 'conversations/t1'), convo));
  await assertFails(updateDoc(doc(db(ACADEMY), 'conversations/t1'), { userId: ACADEMY }));
  await assertFails(updateDoc(doc(db(TRAINEE), 'conversations/t1'), { userId: STRANGER }));
});

// ---------- storage: voice notes ----------
const audio = new Uint8Array([0, 1, 2, 3]);

test('storage: parties upload/read voice notes; stranger cannot', async () => {
  await seed((d) => setDoc(doc(d, 'conversations/t1'), convo));
  const path = 'voice/t1/m1.m4a';
  await assertSucceeds(uploadBytes(ref(st(TRAINEE), path), audio, { contentType: 'audio/mp4' }));
  await assertSucceeds(getBytes(ref(st(ACADEMY), path)));
  await assertFails(getBytes(ref(st(STRANGER), path)));
  await assertFails(uploadBytes(ref(st(STRANGER), 'voice/t1/m2.m4a'), audio, { contentType: 'audio/mp4' }));
});

test('storage: only audio, max 5MB', async () => {
  await seed((d) => setDoc(doc(d, 'conversations/t1'), convo));
  await assertFails(uploadBytes(ref(st(TRAINEE), 'voice/t1/x.png'), audio, { contentType: 'image/png' }));
  const big = new Uint8Array(5 * 1024 * 1024 + 1);
  await assertFails(uploadBytes(ref(st(TRAINEE), 'voice/t1/big.m4a'), big, { contentType: 'audio/mp4' }));
});
