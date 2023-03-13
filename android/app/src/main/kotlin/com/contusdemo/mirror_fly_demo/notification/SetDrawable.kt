package com.contusdemo.mirror_fly_demo.notification

import android.content.Context
import android.graphics.drawable.Drawable
import androidx.core.content.ContextCompat
import com.contus.flycommons.Constants
import com.contusdemo.mirror_fly_demo.R
import com.contusflysdk.api.ChatManager
import com.contusflysdk.api.contacts.ProfileDetails
import java.util.regex.Pattern
import kotlin.math.abs

/**
 *
 * @author ContusTeam <developers@contus.in>
 * @version 1.0
 */
class SetDrawable {

    private var context: Context? = null
    private var profileDetails: ProfileDetails? = null
    private val emojiPattern: Pattern = Pattern.compile("^[\\s\n\r]*(?:(?:[\u00a9\u00ae\u203c\u2049\u2122\u2139\u2194-\u2199\u21a9-\u21aa\u231a-\u231b\u2328\u23cf\u23e9-\u23f3\u23f8-" +
            "\u23fa\u24c2\u25aa-\u25ab\u25b6\u25c0\u25fb-\u25fe\u2600-\u2604\u260e\u2611\u2614-\u2615\u2618\u261d\u2620\u2622-\u2623\u2626\u262a\u262e-\u262f\u2638-\u263a\u2648-" +
            "\u2653\u2660\u2663\u2665-\u2666\u2668\u267b\u267f\u2692-\u2694\u2696-\u2697\u2699\u269b-\u269c\u26a0-\u26a1\u26aa-\u26ab\u26b0-\u26b1\u26bd-\u26be\u26c4-" +
            "\u26c5\u26c8\u26ce-\u26cf\u26d1\u26d3-\u26d4\u26e9-\u26ea\u26f0-\u26f5\u26f7-\u26fa\u26fd\u2702\u2705\u2708-\u270d\u270f\u2712\u2714\u2716\u271d\u2721\u2728\u2733-" +
            "\u2734\u2744\u2747\u274c\u274e\u2753-\u2755\u2757\u2763-\u2764\u2795-\u2797\u27a1\u27b0\u27bf\u2934-\u2935\u2b05-\u2b07\u2b1b-" +
            "\u2b1c\u2b50\u2b55\u3030\u303d\u3297\u3299\ud83c\udc04\ud83c\udccf\ud83c\udd70-\ud83c\udd71\ud83c\udd7e-\ud83c\udd7f\ud83c\udd8e\ud83c\udd91-\ud83c\udd9a\ud83c\ude01-" +
            "\ud83c\ude02\ud83c\ude1a\ud83c\ude2f\ud83c\ude32-\ud83c\ude3a\ud83c\ude50-\ud83c\ude51\u200d\ud83c\udf00-\ud83d\uddff\ud83d\ude00-\ud83d\ude4f\ud83d\ude80-" +
            "\ud83d\udeff\ud83e\udd00-\ud83e\uddff\udb40\udc20-\udb40\udc7f]|\u200d[\u2640\u2642]|[\ud83c\udde6-\ud83c\uddff]{2}|.[\u20e0\u20e3\ufe0f]+)+[\\s\n\r]*)+$")

    constructor(context: Context) {
        this.context = context
    }

    constructor(context: Context, profileDetails: ProfileDetails?) {
        this.context = context
        this.profileDetails = profileDetails
    }

    @Synchronized
    fun setDrawable(name: String): Drawable? {
        var nameValue = name
        nameValue = nameValue.trim { it <= ' ' }.replace("\\s+".toRegex(), " ")
        context?.let { context ->
            profileDetails?.let { profileDetails ->
                val icon = CustomDrawable(context)
                return if (profileDetails.name.isNullOrBlank())
                    ContextCompat.getDrawable(context, R.drawable.ic_profile)
                else {
                    val initialName = nameValue.split(" ".toRegex()).toTypedArray()
                    if (initialName.size == 1) {
                        val charLength = initialName[0].toCharArray().size
                        when {
                            charLength <= 0 -> {
                                icon.setDrawableColour(nameValue.getColourCode())
                                icon.setText("")
                                icon
                            }
                            charLength <= 1 -> {
                                val firstLetter = String(Character.toChars(initialName[0].codePointAt(0)))
                                icon.setDrawableColour(nameValue.getColourCode())
                                icon.setText(firstLetter.toUpperCase())
                                icon
                            }
                            else -> {
                                val firstLetter = String(Character.toChars(initialName[0].codePointAt(0)))
                                val secondLetter = String(Character.toChars(initialName[0].codePointAt(1)))
                                icon.setDrawableColour(nameValue.getColourCode())
                                icon.setText(firstLetter.toUpperCase() + secondLetter.toUpperCase())
                                icon
                            }
                        }
                    } else {
                        val firstLetter = String(Character.toChars(initialName[0].codePointAt(0)))
                        val secondLetter = String(Character.toChars(initialName[1].codePointAt(0)))
                        icon.setText(firstLetter.toUpperCase() + secondLetter.toUpperCase())
                        icon.setDrawableColour(nameValue.getColourCode())
                        icon
                    }
                }
            }
        }
        return null
    }

    fun String?.getColourCode(): Int {
        if (this != null && this == Constants.YOU)
            return ContextCompat.getColor(ChatManager.applicationContext, R.color.color_black)

        val colorsArray = ChatManager.applicationContext.resources.getIntArray(R.array.colour_code)
        val hashcode = this.hashCode()
        val rand =  hashcode % colorsArray.size
        return colorsArray[abs(rand)]
    }
    fun setDrawableForProfile(name: String?): Drawable {
        var nameValue = name
        val icon = CustomDrawable(context!!)
        if (nameValue.isNullOrBlank()) {
            //default
            icon.setDrawableColour(R.color.colorSecondary)
            icon.setText("")
            return icon
        }
        nameValue = nameValue.trim { it <= ' ' }
        val initialName = nameValue.split("\\s+".toRegex()).toTypedArray()
        return if (initialName.size == 1) {
            val username = initialName[0].trim { it <= ' ' }
            when {
                username.isEmpty() -> {
                    icon.setDrawableColour(R.color.colorSecondary)
                    icon.setText("")
                    icon
                }
                username.length == 1 -> {
                    icon.setText(username.toUpperCase())
                    icon.setDrawableProfileColour(R.color.colorSecondary)
                    icon
                }
                else -> {
                    icon.setText(getProfileNameIcon(username))
                    icon.setDrawableProfileColour(R.color.colorSecondary)
                    icon
                }
            }
        } else {
            var firstletter = ""
            if (initialName[0].trim { it <= ' ' }.isNotEmpty()) {
                firstletter = String(Character.toChars(initialName[0].trim { it <= ' ' }.codePointAt(0)))
            }
            var secondletter = ""
            if (initialName[1].trim { it <= ' ' }.isNotEmpty()) {
                secondletter = String(Character.toChars(initialName[1].trim { it <= ' ' }.codePointAt(0)))
            }
            icon.setText(firstletter.toUpperCase() + secondletter.toUpperCase())
            icon.setDrawableProfileColour(R.color.colorSecondary)
            icon
        }
    }


    fun setDrawableForCustomName(name: String): Drawable {
        val icon = CustomDrawable(context!!, R.color.color_black)
        icon.setDrawableColour(ContextCompat.getColor(context!!, R.color.color_white))
        icon.setText(name)
        return icon
    }

    private fun isEmojiOnly(string: String): Boolean? {
        return emojiPattern.matcher(string).find()
    }

    private fun getProfileNameIcon(username: String): String {
        var profileLetters = username.substring(0, 2)
        if (isEmojiOnly(profileLetters) == true) {
            profileLetters = if (isEmojiOnly(username.substring(0, 4)) == true) username.substring(0, 4) else username.substring(0, 3)
        }
        return profileLetters.toUpperCase()
    }
}