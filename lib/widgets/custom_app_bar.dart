import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBrandLogo;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBrandLogo = false,
    this.showBackButton = true,
    this.onBack,
    this.actions,
    this.backgroundColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.surface,
      elevation: 0,
      centerTitle: false,
      leading: showBackButton && Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppColors.onSurface,
              ),
              onPressed: onBack ?? () => Navigator.maybePop(context),
            )
          : null,
      title: showBrandLogo
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    text: 'Citizen',
                    style: AppTypography.brandTitle.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 20,
                    ),
                    children: [
                      TextSpan(
                        text: 'Connect',
                        style: AppTypography.brandTitle.copyWith(
                          color: AppColors.primary,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : (title != null
              ? Text(
                  title!,
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
