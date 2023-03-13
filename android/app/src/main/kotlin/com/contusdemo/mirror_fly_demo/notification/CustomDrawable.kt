package com.contusdemo.mirror_fly_demo.notification

import android.content.Context
import android.graphics.*
import android.graphics.drawable.Drawable
import android.os.Build
import android.util.TypedValue
import androidx.annotation.ColorInt
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import com.contusdemo.mirror_fly_demo.R

class CustomDrawable : Drawable {
    val context: Context
    private var text: String? = null
    private var paint: Paint
    private var intrinsicSize: Int
    private var drawable: Drawable? = null

    constructor(context: Context, color:Int = Color.WHITE) {
        this.context = context
        paint = Paint()
        paint.color = color
        paint.textSize = DEFAULT_TEXT_SIZE.toFloat()
        paint.isAntiAlias = true
        paint.isFakeBoldText = true
        if (color == Color.WHITE)
            paint.setShadowLayer(20f, 0f, 0f, Color.GRAY)
        paint.style = Paint.Style.FILL
        paint.textAlign = Paint.Align.CENTER
        intrinsicSize = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, DRAWABLE_SIZE.toFloat(), context.resources.displayMetrics).toInt()
    }

    constructor(context: Context, drawableSize: Float) {
        this.context = context
        paint = Paint()
        paint.color = Color.WHITE
        paint.textSize = DEFAULT_TEXT_SIZE.toFloat()
        paint.isAntiAlias = true
        paint.isFakeBoldText = true
        paint.setShadowLayer(20f, 0f, 0f, Color.GRAY)
        paint.style = Paint.Style.FILL
        paint.textAlign = Paint.Align.CENTER
        intrinsicSize = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, drawableSize, context.resources.displayMetrics).toInt()
    }

    fun setDrawableColour(colourCode: Int) {
        drawable = AppCompatResources.getDrawable(context, R.drawable.custom_drawable)
        assert(drawable != null)
        drawable!!.setBounds(0, 0, intrinsicSize, intrinsicSize)
        drawable!!.setColorFilter(colourCode, PorterDuff.Mode.LIGHTEN)
    }

    fun setTransparentDrawableColour(colourCode: Int) {
        drawable = AppCompatResources.getDrawable(context, R.drawable.custom_drawable)
        assert(drawable != null)
        drawable!!.setBounds(0, 0, intrinsicSize, intrinsicSize)
        drawable!!.applySrcInColorFilter(ContextCompat.getColor(context, colourCode))
    }
    fun Drawable.applySrcInColorFilter(@ColorInt color: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            colorFilter = BlendModeColorFilter(color, BlendMode.SRC_IN)
        } else {
            setColorFilter(color, PorterDuff.Mode.SRC_IN)
        }
    }
    fun setDrawableProfileColour(colourCode: Int) {
        drawable = AppCompatResources.getDrawable(context, R.drawable.custom_profile_drawable)
        assert(drawable != null)
        drawable!!.setBounds(0, 0, intrinsicSize, intrinsicSize)
        drawable!!.setColorFilter(colourCode, PorterDuff.Mode.LIGHTEN)
    }

    fun setText(text: String?) {
        this.text = text
        invalidateSelf()
    }

    override fun draw(canvas: Canvas) {
        val bounds = bounds
        drawable!!.draw(canvas)
        canvas.drawText(text!!, 0, text!!.length,
                bounds.centerX().toFloat(), bounds.centerY() + paint.getFontMetricsInt(null) / 3.toFloat(), paint)
    }

    override fun setAlpha(alpha: Int) {
        paint.alpha = alpha
    }

    override fun setColorFilter(colorFilter: ColorFilter?) {
        paint.colorFilter = colorFilter
    }

    override fun getIntrinsicWidth(): Int {
        return intrinsicSize
    }

    override fun getIntrinsicHeight(): Int {
        return intrinsicWidth
    }

    override fun getOpacity(): Int {
        return PixelFormat.TRANSLUCENT
    }

    companion object {
        private const val DRAWABLE_SIZE = 130
        private const val DEFAULT_TEXT_SIZE = 120
    }
}