package com.coffeecall.app.core.design

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val LightColors = lightColorScheme(
    primary = CoffeePrimary,
    secondary = CoffeePurple,
    tertiary = CoffeePeach,
    background = CoffeeBackground,
    surface = CoffeeSurface,
    surfaceVariant = CoffeeSurfaceSecondary,
    outline = CoffeeBorder,
    error = CoffeeError,
    onPrimary = CoffeeSurface,
    onSecondary = CoffeeSurface,
    onTertiary = CoffeeInk,
    onBackground = CoffeeInk,
    onSurface = CoffeeInk,
    onSurfaceVariant = CoffeeMuted
)

private val DarkColors = darkColorScheme(
    primary = CoffeePrimary,
    secondary = CoffeePurple,
    tertiary = CoffeePeach,
    background = CoffeeInk,
    surface = Color(0xFF2E2927),
    surfaceVariant = Color(0xFF3A3431),
    outline = CoffeeBorder.copy(alpha = 0.34f),
    onPrimary = CoffeeTextOnBrand,
    onSecondary = CoffeeTextOnBrand,
    onTertiary = CoffeeInk,
    onBackground = CoffeeSurface,
    onSurface = CoffeeSurface,
    onSurfaceVariant = CoffeeSurfaceSecondary
)

@Composable
fun CoffeeCallTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = if (darkTheme) DarkColors else LightColors,
        typography = CoffeeTypography,
        shapes = androidx.compose.material3.Shapes(
            extraSmall = CoffeeShapes.tiny,
            small = CoffeeShapes.small,
            medium = CoffeeShapes.medium,
            large = CoffeeShapes.large,
            extraLarge = CoffeeShapes.xlarge
        ),
        content = content
    )
}
