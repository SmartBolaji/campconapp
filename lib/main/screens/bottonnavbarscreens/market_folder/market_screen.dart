import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/market_provider.dart';
import 'package:campcon/main/widgets/market/empty_state.dart';
import 'package:campcon/main/widgets/market/market_tabbar.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/market_folder/post_product.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/market_folder/post_service_screen.dart';
import 'package:campcon/main/widgets/market/product_card.dart';
import 'package:campcon/main/widgets/post_optionbtn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        child: Icon(
                          Icons.person,
                          size: 15.sp,
                        ),
                      ),
                      Text('Marketplace', style: TextConstants.mediumText),
                      GestureDetector(
                        onTap: () => showPostOptions(context),
                        child: CircleAvatar(
                          backgroundColor: Constants.primaryDark,
                          child: Icon(
                            Icons.add,
                            size: 25.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    decoration: BoxDecoration(
                      color: Constants.background,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextConstants.smallText,
                        filled: true,
                        fillColor: Constants.background,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  TabBarWidget(
                    selectedTab: provider.selectedTab,
                    onTabChanged: (index) {
                      provider.changeTab(index);
                    },
                  ),
                  SizedBox(height: 20.h),
                
                  provider.currentList.isEmpty
                      ? EmptyStateWidget(
                          isItem: provider.selectedTab == 0,
                          onAddPressed: () => showPostOptions(context),
                        )
                      : SizedBox(
                          height: 200.h,
                          child: ProductGridView(
                            products: provider.currentList,
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return PostOptionsBottomSheet(
          onItemTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PostItemScreen(),
              ),
            );
          },
          onServiceTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PostServiceScreen(),
              ),
            );
          },
        );
      },
    );
  }
}

class PostOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onItemTap;
  final VoidCallback onServiceTap;

  const PostOptionsBottomSheet({
    Key? key,
    required this.onItemTap,
    required this.onServiceTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PostOptionButton(
                icon: Icons.shopping_bag_outlined,
                label: 'List an Item',
                onTap: onItemTap,
              ),
              PostOptionButton(
                icon: Icons.home_repair_service_outlined,
                label: 'List a service',
                onTap: onServiceTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
