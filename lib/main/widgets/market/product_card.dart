import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/product_model.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/market_folder/product_decription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

class ProductGridView extends StatelessWidget {
  final List<Product> products;

  const ProductGridView({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: ProductCard(product: products[index]),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: ProductDecription(
              product: product,
            ),
            duration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Constants.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12.r)),
                ),
                child: product.imageFile != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12.r)),
                        child: Image.file(
                          product.imageFile!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 50.sp,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextConstants.smallText,
                    // (
                    //   fontSize: 14.sp,
                    //   fontWeight: FontWeight.w600,
                    // ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.price.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      product.price,
                      style: TextConstants.smallText.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Constants.black,
                      ),
                    ),
                  ],
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: Constants.textLight),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          product.location,
                          style: TextConstants.smallText.copyWith(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
