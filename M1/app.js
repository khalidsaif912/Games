/*************************************************
 * app.js - Memory Pair Game (Firebase + Manifest)
 *************************************************/

// ===== Firebase (CDN - Modular v10) =====
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
import {
  getAuth,
  signInAnonymously,
  onAuthStateChanged
} from "https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js";
import {
  getFirestore,
  collection,
  addDoc,
  serverTimestamp,
  query,
  orderBy,
  limit,
  getDocs
} from "https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js";

/* =================================================
   🔴 عدّل هذا الجزء فقط (firebaseConfig)
   ================================================= */
const firebaseConfig = {
  apiKey: "AIzaSyD4wKBL-frMWN9Cw7uJFsyaHCk963JRUuA",
  authDomain: "similarity-f2428.firebaseapp.com",
  projectId: "similarity-f2428",
  storageBucket: "similarity-f2428.firebasestorage.app",
  messagingSenderId: "353323874706",
  appId: "1:353323874706:web:7999c84682c30f6800694b",
  measurementId: "G-X5E3CC8RZF"
};
/* ================================================= */

// تهيئة Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

// ===== إعدادات اللعبة =====
const PAIRS_PER_GAME = 10;

// رابط manifest.json
const MANIFEST_URL =
  "https://raw.githubusercontent.com/khalidsaif912/Games/main/M1/manifest.json";

// رابط مجلد الصور
const IMAGES_BASE =
  "https://raw.githubusercontent.com/khalidsaif912/Games/main/M1/";

// ===== عناصر الواجهة =====
const gridEl = document.getElementById("grid");
const timeEl = document.getElementById("time");
const movesEl = document.getElementById("moves");
const matchesEl = document.getElementById("matches");
const playerEl = document.getElementById("playerName");

const startOverlay = document.getElementById("startOverlay");
const winOverlay = document.getElementById("winOverlay");
const winTitle = document.getElementById("winTitle");
const winText = document.getElementById("winText");
const statusLine = document.getElementById("statusLine");
const submitStatus = document.getElementById("submitStatus");
const leaderboardEl = document.getElementById("leaderboard");

// ===== الحالة =====
let manifestPairs = [];
let cards = [];
let first = null;
let second = null;
let lock = false;
let moves = 0;
let matches = 0;
let seconds = 0;
let timer = null;
let started = false;
let canSubmit = false;

// ===== أدوات مساعدة =====
function shuffle(arr) {
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

function formatTime(sec) {
  const m = String(Math.floor(sec / 60)).padStart(2, "0");
  const s = String(sec % 60).padStart(2, "0");
  return `${m}:${s}`;
}

function updateHUD() {
  timeEl.textContent = formatTime(seconds);
  movesEl.textContent = moves;
  matchesEl.textContent = matches;
}

// ===== المؤقت =====
function startTimer() {
  if (timer) clearInterval(timer);
  timer = setInterval(() => {
    seconds++;
    updateHUD();
  }, 1000);
}

function stopTimer() {
  if (timer) clearInterval(timer);
  timer = null;
}

// ===== تحميل manifest =====
async function loadManifest() {
  statusLine.textContent = "تحميل الصور...";
  const res = await fetch(MANIFEST_URL, { cache: "no-store" });
  if (!res.ok) throw new Error("فشل تحميل manifest.json");
  const data = await res.json();
  manifestPairs = data.pairs || [];
  statusLine.textContent = `تم العثور على ${manifestPairs.length} زوج`;
}

// ===== إنشاء الكروت =====
function buildDeck() {
  const pairs = shuffle([...manifestPairs]).slice(
    0,
    Math.min(PAIRS_PER_GAME, manifestPairs.length)
  );

  const deck = [];
  pairs.forEach(p => {
    deck.push({ pair: p.id, img: IMAGES_BASE + p.img1 });
    deck.push({ pair: p.id, img: IMAGES_BASE + p.img2 });
  });

  return shuffle(deck);
}

function renderDeck(deck) {
  gridEl.innerHTML = "";
  deck.forEach(card => {
    const btn = document.createElement("button");
    btn.className = "card";
    btn.dataset.pair = card.pair;
    btn.innerHTML = `
      <div class="cardInner">
        <div class="face front">؟</div>
        <div class="face back">
          <img src="${card.img}" loading="lazy">
        </div>
      </div>
    `;
    btn.onclick = () => onCardClick(btn);
    gridEl.appendChild(btn);
  });
}

// ===== منطق اللعب =====
function onCardClick(card) {
  if (lock || card.classList.contains("matched") || card === first) return;

  card.classList.add("flipped");

  if (!started) {
    started = true;
    startTimer();
  }

  if (!first) {
    first = card;
    return;
  }

  second = card;
  moves++;
  updateHUD();

  if (first.dataset.pair === second.dataset.pair) {
    first.classList.add("matched");
    second.classList.add("matched");
    matches++;
    first = second = null;
    updateHUD();

    if (matches === PAIRS_PER_GAME) finishGame();
  } else {
    lock = true;
    setTimeout(() => {
      first.classList.remove("flipped");
      second.classList.remove("flipped");
      first = second = null;
      lock = false;
    }, 700);
  }
}

// ===== نهاية اللعبة =====
function finishGame() {
  stopTimer();
  canSubmit = true;
  winTitle.textContent = "🎉 فزت!";
  winText.textContent =
    `الوقت: ${formatTime(seconds)} | المحاولات: ${moves}`;
  winOverlay.classList.add("show");
}

// ===== Leaderboard =====
async function loadLeaderboard() {
  leaderboardEl.innerHTML = "<li>تحميل...</li>";
  const q = query(
    collection(db, "scores"),
    orderBy("timeSeconds", "asc"),
    orderBy("moves", "asc"),
    limit(20)
  );
  const snap = await getDocs(q);
  leaderboardEl.innerHTML = "";
  snap.forEach((doc, i) => {
    const d = doc.data();
    const li = document.createElement("li");
    li.textContent =
      `${i + 1}. ${d.playerName} - ${formatTime(d.timeSeconds)} - ${d.moves}`;
    leaderboardEl.appendChild(li);
  });
}

async function submitScore() {
  if (!canSubmit) return;
  canSubmit = false;

  await addDoc(collection(db, "scores"), {
    playerName: playerEl.textContent || "زائر",
    timeSeconds: seconds,
    moves,
    pairsCount: PAIRS_PER_GAME,
    createdAt: serverTimestamp(),
    uid: auth.currentUser.uid
  });

  submitStatus.textContent = "تم حفظ النتيجة ✅";
  loadLeaderboard();
}

// ===== أحداث الواجهة =====
document.getElementById("submitScoreBtn").onclick = submitScore;
document.getElementById("playAgainBtn").onclick = () => location.reload();
document.getElementById("closeWinBtn").onclick = () =>
  winOverlay.classList.remove("show");

// ===== تشغيل التطبيق =====
async function boot() {
  await loadManifest();
  await signInAnonymously(auth);
  onAuthStateChanged(auth, () => {
    loadLeaderboard();
  });
}

boot();
