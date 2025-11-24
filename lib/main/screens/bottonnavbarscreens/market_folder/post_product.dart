import 'dart:io';

import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/models/product_model.dart';

import 'package:campcon/main/provider/market_provider.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:campcon/main/widgets/market/customInputfield.dart';
import 'package:campcon/main/widgets/market/customcategory.dart';
import 'package:campcon/main/widgets/market/image_upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PostItemScreen extends StatefulWidget {
  const PostItemScreen({Key? key}) : super(key: key);

  @override
  State<PostItemScreen> createState() => PostItemScreenState();
}

class PostItemScreenState extends State<PostItemScreen> {
  File? selectedImage;
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  String? selectedCategory;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void postItem() {
    if (nameController.text.isEmpty ||
        locationController.text.isEmpty ||
        selectedCategory == null ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final product = Product(
      name: nameController.text,
      price: priceController.text.isNotEmpty ? 'N${priceController.text}' : '',
      location: locationController.text,
      imageFile: selectedImage,
      isItem: true,
      description: descriptionController.text,
      category: selectedCategory!,
    );

    Provider.of<MarketplaceProvider>(context, listen: false).addProduct(product);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item posted successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Post Item',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInputField(
                label: 'Location',
                controller: locationController,
              ),
              SizedBox(height: 20.h),
              CustomInputField(
                label: 'Item name',
                controller: nameController,
              ),
              SizedBox(height: 20.h),
              CustomInputField(
                label: 'Price (optional)',
                controller: priceController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20.h),
              CustomCategoryDropdown(
                selectedCategory: selectedCategory,
                categories: ['Electronics', 'Fashion', 'Books', 'Furniture', 'Sports', 'Others'],
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
              SizedBox(height: 20.h),
              CustomInputField(
                label: 'Write a short description for your item',
                controller: descriptionController,
                maxLines: 3,
              ),
              SizedBox(height: 20.h),
              CustomImageUpload(
                label: 'Item Image',
                selectedImage: selectedImage,
                onTap: pickImage,
              ),
              SizedBox(height: 40.h),
              CustomButton(
                text: 'Post Service',
                onPressed: () => postItem(),
                backgroundColor: Constants.primaryDark,
                textColor: Constants.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }
}