// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:campcon/main/screens/bottonnavbarscreens/market_folder/market_chat.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/product_model.dart';

class ProductDecription extends StatefulWidget {
  final Product product;
  final bool isSeller;
  const ProductDecription({
    Key? key,
    required this.product,
    this.isSeller = false,
  }) : super(key: key);

  @override
  State<ProductDecription> createState() => _ProductDecriptionState();
}

class _ProductDecriptionState extends State<ProductDecription> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(child: Divider(color: Constants.textLight))
                ],
              ),
              Container(
                padding: EdgeInsets.all(10.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 300.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Constants.primarybackground,
                          borderRadius: BorderRadius.circular(16.r)),
                      child: widget.product.imageFile != null
                          ? Image.file(
                              widget.product.imageFile!,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              widget.product.isItem
                                  ? Icons.shopping_bag
                                  : Icons.person,
                              size: 100.sp,
                              color: Constants.primaryColors,
                            ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.product.name,
                          style: TextConstants.mediumText.copyWith(),
                        ),
                        Text(
                          widget.product.price.toString(),
                          style: TextConstants.mediumText.copyWith(),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 20.sp, color: Constants.primaryColors),
                        SizedBox(width: 5.w),
                        Text(
                          widget.product.location,
                          style: TextConstants.smallText
                              .copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Description",
                      style: TextConstants.smallText.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 20.sp),
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      widget.product.description,
                      style: TextConstants.smallText.copyWith(
                        color: Constants.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    if (!widget.isSeller)
                      CustomButton(
                        text:
                            'Chat with ${widget.product.isItem ? 'Seller' : 'Provider'}',
                        onPressed: () {
                          // Navigate to the Chat Screen (Buyer Side)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                recipientName:
                                    'Balo Agbotor', // Placeholder for actual user name
                                productName: widget.product.name,
                                isOrderChat: true,
                                conversationId:
                                    '', // Indicate it's an order/product-related chat
                              ),
                            ),
                          );
                        },
                        backgroundColor: Constants.primaryDark,
                        textColor: Constants.textPrimary,
                      ),

                    // Seller specific actions (Optional: e.g., Edit/Delete)
                    if (widget.isSeller)
                      Column(
                        children: [
                          CustomButton(
                            text: 'View Orders/Offers',
                            onPressed: () {
                              // Logic to view pending offers/orders for the product
                            },
                            backgroundColor: Constants.primaryDark,
                            textColor: Constants.textPrimary,
                          ),
                          SizedBox(height: 10.h),
                          CustomButton(
                            text: 'Edit Listing',
                            onPressed: () {
                              // Logic to edit the product
                            },
                            backgroundColor: Constants.textSecondary,
                            textColor: Constants.black,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
