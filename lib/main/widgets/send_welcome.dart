// import 'package:flutter/material.dart';
// import 'package:cloud_functions/cloud_functions.dart';

// Future<void> sendWelcomeEmail({
//   required String toEmail,
//   required String userName,
// }) async {
//   try {
//     await FirebaseFunctions.instance.httpsCallable('sendWelcomeEmail').call({
//       'toEmail': toEmail,
//       'userName': userName,
//     });

//     debugPrint('Welcome email sent to $toEmail');
//   } catch (e) {
//     debugPrint('Failed to send welcome email: $e');
//   }
// }


// // Send welcome email
// exports.sendWelcomeEmail = onCall({
//   secrets: [resendApiKey],
// }, async (request) => {
//   const {toEmail, userName} = request.data;

//   if (!toEmail || !userName) {
//     throw new Error("Email and username are required");
//   }

//   const htmlContent = `
//     <div style="font-family: 'Segoe UI', 'Nexa Light', Arial, sans-serif; color: #222;">
//       <h2 style="color:#a62c71;">Welcome to DressFli, ${userName}!</h2>
//       <p>
//         We're thrilled to have you join our fashion community.<br>
//         At DressFli, every day is a new opportunity to express yourself, discover inspiration, and connect with fashion lovers worldwide.
//       </p>
//       <p>
//         <b>What makes DressFli special?</b>
//         <ul>
//           <li>Showcase your unique outfits and inspire others</li>
//           <li>Explore a world of trends, brands, and creative looks</li>
//           <li>Find and tag products directly in your posts</li>
//           <li>Build your own following and connect with fellow creators</li>
//         </ul>
//       </p>
//       <p>
//         <b>Jump in and make the most of your DressFli experience:</b>
//         <ul>
//           <li>Enjoy a personalized feed curated just for you</li>
//           <li>Unlock exclusive discounts and early access to new drops</li>
//           <li>Start posting your favorite styles and get featured</li>
//           <li>Follow top creators, brands, and join style challenges</li>
//           <li>Share, shop, and celebrate fashion your way!</li>
//         </ul>
//         Open the DressFli app and start your style journey today!
//       </p>
//       <p style="margin-top:32px; color:#888;">
//         Need help or have feedback? 
//         We're here for you—just contact <a href="mailto:support@dressfli.com" style="color:#a62c71;">support@dressfli.com</a>.
//       </p>
//       <p style="margin-top:24px;">
//         Happy styling,<br>
//         <b>The DressFli Team</b>
//       </p>
//     </div>
//   `;

//   try {
//     const response = await fetch("https://api.resend.com/emails", {
//       method: "POST",
//       headers: {
//         "Authorization": `Bearer ${resendApiKey.value()}`,
//         "Content-Type": "application/json",
//       },
//       body: JSON.stringify({
//         from: "DressFli <no-reply@dressfli.com>",
//         to: toEmail,
//         subject: "Welcome to DressFli!",
//         html: htmlContent,
//       }),
//     });

//     if (!response.ok) {
//       throw new Error(`Email send failed: ${response.statusText}`);
//     }

//     return {success: true};
//   } catch (error) {
//     console.error("Error sending welcome email:", error);
//     throw new Error("Failed to send welcome email");
//   }
// });