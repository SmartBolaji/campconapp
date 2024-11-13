// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyAaR7kr04Ctx1b0vR90NIvHQkTIUCQt6U4",
  authDomain: "campcon-806c3.firebaseapp.com",
  projectId: "campcon-806c3",
  storageBucket: "campcon-806c3.firebasestorage.app",
  messagingSenderId: "987673267133",
  appId: "1:987673267133:web:001190399865d1c966e0d4",
  measurementId: "G-PJ745LVF57"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);