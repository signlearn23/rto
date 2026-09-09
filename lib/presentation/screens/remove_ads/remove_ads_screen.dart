import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_state_provider.dart';

/// ₹39 one-time non-consumable purchase to remove ads permanently
/// (and grant unlimited exam attempts, since ads are what gate them).
class RemoveAdsScreen extends StatefulWidget {
  const RemoveAdsScreen({super.key});

  @override
  State<RemoveAdsScreen> createState() => _RemoveAdsScreenState();
}

class _RemoveAdsScreenState extends State<RemoveAdsScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;
  bool _loading = true;
  bool _purchasing = false;
  ProductDetails? _product;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _available = await _iap.isAvailable();
    if (_available) {
      final response = await _iap.queryProductDetails({AppConstants.removeAdsProductId});
      if (response.productDetails.isNotEmpty) {
        _product = response.productDetails.first;
      }
      _iap.purchaseStream.listen(_onPurchaseUpdate);
    }
    setState(() => _loading = false);
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        await context.read<AppStateProvider>().markAdsRemoved();
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        if (mounted) {
          setState(() => _purchasing = false);
          Navigator.of(context).pop();
        }
      } else if (purchase.status == PurchaseStatus.error) {
        setState(() => _purchasing = false);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Purchase failed. Please try again.')));
        }
      }
    }
  }

  Future<void> _buy() async {
    if (_product == null) return;
    setState(() => _purchasing = true);
    final param = PurchaseParam(productDetails: _product!);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remove Ads')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.workspace_premium_rounded,
                        size: 64, color: AppColors.accent),
                  ),
                  const SizedBox(height: 24),
                  Text(_product?.price ?? AppConstants.removeAdsPriceLabel,
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                  const Text('One-time payment', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  const _Benefit(text: 'No banner ads anywhere in the app'),
                  const _Benefit(text: 'Unlimited Exam Mode attempts — no rewarded ads needed'),
                  const _Benefit(text: 'Support continued development'),
                  const Spacer(),
                  if (!_available)
                    const Text('In-app purchases are unavailable on this device.',
                        style: TextStyle(color: Colors.red)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (!_available || _purchasing) ? null : _buy,
                      child: _purchasing
                          ? const SizedBox(
                              width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                          : const Text('Remove Ads Now'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final String text;
  const _Benefit({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
