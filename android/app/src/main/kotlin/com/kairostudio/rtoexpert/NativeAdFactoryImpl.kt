package com.kairostudio.rtoexpert

import android.content.Context
import android.view.LayoutInflater
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

class NativeAdFactoryImpl(private val context: Context) : NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_advanced, null) as NativeAdView

        val headline = adView.findViewById<TextView>(R.id.ad_headline)
        val body = adView.findViewById<TextView>(R.id.ad_body)
        val cta = adView.findViewById<Button>(R.id.ad_call_to_action)
        val icon = adView.findViewById<ImageView>(R.id.ad_app_icon)
        val advertiser = adView.findViewById<TextView>(R.id.ad_advertiser)
        val stars = adView.findViewById<RatingBar>(R.id.ad_stars)
        val media = adView.findViewById<MediaView>(R.id.ad_media)

        headline.text = nativeAd.headline
        adView.headlineView = headline

        if (nativeAd.body == null) {
            body.visibility = android.view.View.GONE
        } else {
            body.text = nativeAd.body
            body.visibility = android.view.View.VISIBLE
        }
        adView.bodyView = body

        if (nativeAd.callToAction == null) {
            cta.visibility = android.view.View.GONE
        } else {
            cta.text = nativeAd.callToAction
            cta.visibility = android.view.View.VISIBLE
        }
        adView.callToActionView = cta

        if (nativeAd.icon == null) {
            icon.visibility = android.view.View.GONE
        } else {
            icon.setImageDrawable(nativeAd.icon?.drawable)
            icon.visibility = android.view.View.VISIBLE
        }
        adView.iconView = icon

        if (nativeAd.advertiser == null) {
            advertiser.visibility = android.view.View.GONE
        } else {
            advertiser.text = nativeAd.advertiser
            advertiser.visibility = android.view.View.VISIBLE
        }
        adView.advertiserView = advertiser

        if (nativeAd.starRating == null) {
            stars.visibility = android.view.View.GONE
        } else {
            stars.rating = nativeAd.starRating!!.toFloat()
            stars.visibility = android.view.View.VISIBLE
        }
        adView.starRatingView = stars

        adView.mediaView = media
        nativeAd.mediaContent?.let { media.mediaContent = it }

        adView.setNativeAd(nativeAd)
        return adView
    }
}
