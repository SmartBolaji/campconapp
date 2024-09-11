// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyBfy2JhE3QMrreM4BOCdyOP3emn9jNOHJ8",
  authDomain: "paytmmatka.firebaseapp.com",
  projectId: "paytmmatka",
  storageBucket: "paytmmatka.appspot.com",
  messagingSenderId: "273504583231",
  appId: "1:273504583231:web:bc0fea2817462d9f42828a",
  measurementId: "G-KY4SMXLNQW"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
