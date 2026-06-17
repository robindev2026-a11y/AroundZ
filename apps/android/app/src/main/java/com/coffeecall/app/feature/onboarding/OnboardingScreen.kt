package com.coffeecall.app.feature.onboarding

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.coffeecall.app.core.design.*

// MARK: - Onboarding Image Constants
private object OnboardingImages {
    const val heroURL = "https://images.unsplash.com/photo-1670272506160-bdf0c7a45d2b?auto=format&fit=crop&w=1000&q=80"
    const val readyURL = "https://images.unsplash.com/photo-1735335568593-6b9f50ec909d?auto=format&fit=crop&w=1000&q=80"
    val avatars = listOf(
        "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&q=80",
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&q=80",
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&q=80",
        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&q=80"
    )
}

@Composable
fun OnboardingScreen(
    onContinue: () -> Unit
) {
    var currentPage by remember { mutableIntStateOf(0) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
    ) {
        // Unsplash Backgrounds for Slide 1 and Slide 5
        if (currentPage == 0) {
            Box(modifier = Modifier.fillMaxSize()) {
                AsyncImage(
                    model = OnboardingImages.heroURL,
                    contentDescription = null,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(
                            Brush.verticalGradient(
                                colors = listOf(
                                    CoffeeDarkOverlay.copy(alpha = 0.9f),
                                    CoffeeDarkOverlay.copy(alpha = 0.4f),
                                    Color.Transparent
                                )
                            )
                        )
                )
            }
        } else if (currentPage == 4) {
            Box(modifier = Modifier.fillMaxSize()) {
                AsyncImage(
                    model = OnboardingImages.readyURL,
                    contentDescription = null,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(
                            Brush.verticalGradient(
                                colors = listOf(
                                    Color.Black.copy(alpha = 0.05f),
                                    Color.Black.copy(alpha = 0.25f),
                                    Color.Black.copy(alpha = 0.78f)
                                )
                            )
                        )
                )
            }
        }

        // Slides Content
        when (currentPage) {
            0 -> Slide1View(onNext = { currentPage = 1 })
            1 -> Slide2View(onNext = { currentPage = 2 })
            2 -> Slide3View(onNext = { currentPage = 3 })
            3 -> Slide4View(onNext = { currentPage = 4 })
            4 -> Slide5View(onStartExploring = onContinue)
        }
    }
}

// MARK: - Slide 1 (Landing)
@Composable
private fun Slide1View(onNext: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = CoffeeSpacing.xl),
        horizontalAlignment = Alignment.Start
    ) {
        // 1. Beta Badge
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 48.dp),
            contentAlignment = Alignment.Center
        ) {
            Box(
                modifier = Modifier
                    .clip(CircleShape)
                    .background(Color.White.copy(alpha = 0.18f))
                    .border(1.dp, Color.White.copy(alpha = 0.30f), CircleShape)
                    .padding(horizontal = 14.dp, vertical = 6.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Text(
                        text = "✨",
                        fontSize = 12.sp,
                        color = Color.White
                    )
                    Text(
                        text = "COFFEECALL BETA",
                        style = MaterialTheme.typography.labelSmall,
                        color = Color.White,
                        fontWeight = FontWeight.Black,
                        letterSpacing = 1.2.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.weight(1f))

        // 2. Main Headline
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = CoffeeSpacing.xs, vertical = CoffeeSpacing.xl),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xxs)
        ) {
            Text(
                text = "Meet people",
                fontSize = 44.sp,
                fontWeight = FontWeight.Black,
                color = Color.White,
                lineHeight = 48.sp
            )
            Text(
                text = "nearby in",
                fontSize = 44.sp,
                fontWeight = FontWeight.Black,
                color = Color.White,
                lineHeight = 48.sp
            )
            Text(
                text = "real life.",
                fontSize = 44.sp,
                fontWeight = FontWeight.Black,
                color = CoffeePrimary,
                lineHeight = 48.sp
            )
        }

        // 3. Floating Activity Cards
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 40.dp),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
        ) {
            // Left Card (Sunset Walk)
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Start) {
                GlassmorphicCard(
                    modifier = Modifier
                        .width(240.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(CoffeeSpacing.minTouchTarget)
                                .clip(RoundedCornerShape(12.dp))
                                .background(CoffeePrimary),
                            contentAlignment = Alignment.Center
                        ) {
                            Text("🌅", fontSize = 24.sp)
                        }

                        Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                            Text(
                                text = "NOW NEARBY",
                                style = MaterialTheme.typography.labelSmall,
                                color = Color.White.copy(alpha = 0.6f),
                                fontWeight = FontWeight.Black,
                                letterSpacing = 1.2.sp
                            )
                            Text(
                                text = "Sunset Walk + Convo",
                                style = MaterialTheme.typography.titleMedium.copy(fontSize = 14.sp),
                                color = Color.White,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            }

            // Right Card (Photo Session)
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                GlassmorphicCard(
                    modifier = Modifier
                        .width(240.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(CoffeeSpacing.minTouchTarget)
                                .clip(RoundedCornerShape(12.dp))
                                .background(CoffeePurple),
                            contentAlignment = Alignment.Center
                        ) {
                            Text("📸", fontSize = 24.sp)
                        }

                        Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                            Text(
                                text = "12 PEOPLE JOINED",
                                style = MaterialTheme.typography.labelSmall,
                                color = Color.White.copy(alpha = 0.6f),
                                fontWeight = FontWeight.Black,
                                letterSpacing = 1.2.sp
                            )
                            Text(
                                text = "Photo Session at Park",
                                style = MaterialTheme.typography.titleMedium.copy(fontSize = 14.sp),
                                color = Color.White,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            }
        }

        // 4. CTA Button
        CoffeeButton(
            title = "Let's Go →",
            onClick = onNext,
            variant = CoffeeButtonVariant.Primary,
            modifier = Modifier.padding(bottom = CoffeeSpacing.xs),
            height = 64.dp
        )

        Spacer(modifier = Modifier.height(48.dp))
    }
}

// MARK: - Slide 2 (Discovery)
@Composable
private fun Slide2View(onNext: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = CoffeeSpacing.xl)
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.Start
    ) {
        OnboardingProgressBar(
            activeIndex = 0,
            total = 4,
            modifier = Modifier.padding(top = CoffeeSpacing.xl, bottom = 40.dp)
        )

        // Bolt Icon Card
        Box(
            modifier = Modifier
                .size(48.dp)
                .shadow(
                    elevation = 8.dp,
                    shape = CircleShape,
                    ambientColor = Color.Black.copy(alpha = 0.05f),
                    spotColor = Color.Black.copy(alpha = 0.05f)
                )
                .clip(CircleShape)
                .background(Color.White),
            contentAlignment = Alignment.Center
        ) {
            Text("⚡", fontSize = 24.sp)
        }

        Text(
            text = "Discover what's\nhappening nearby.",
            style = MaterialTheme.typography.displaySmall,
            fontWeight = FontWeight.Black,
            color = CoffeeInk,
            modifier = Modifier.padding(top = CoffeeSpacing.xl, bottom = CoffeeSpacing.md)
        )

        Text(
            text = "Coffee chats, walks, gaming, and spontaneous social moments.",
            style = MaterialTheme.typography.bodyLarge,
            color = CoffeeMuted,
            lineHeight = 22.sp,
            modifier = Modifier.padding(bottom = 40.dp)
        )

        // Activity Chips grid
        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
            ) {
                ActivityChip(icon = "☕", title = "COFFEE CHAT", activeCount = 4, modifier = Modifier.weight(1f))
                ActivityChip(icon = "🚶", title = "URBAN WALK", activeCount = 7, modifier = Modifier.weight(1f))
            }
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
            ) {
                ActivityChip(icon = "🎮", title = "GAME NIGHT", activeCount = 12, modifier = Modifier.weight(1f))
                ActivityChip(icon = "🎨", title = "ART JAM", activeCount = 3, modifier = Modifier.weight(1f))
            }
        }

        Spacer(modifier = Modifier.weight(1f))
        Spacer(modifier = Modifier.height(40.dp))

        CoffeeButton(
            title = "Next →",
            onClick = onNext,
            variant = CoffeeButtonVariant.Primary
        )

        Spacer(modifier = Modifier.height(40.dp))
    }
}

// MARK: - Slide 3 (Safety)
@Composable
private fun Slide3View(onNext: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = CoffeeSpacing.xl)
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        OnboardingProgressBar(
            activeIndex = 1,
            total = 4,
            modifier = Modifier.padding(top = CoffeeSpacing.xl, bottom = 40.dp)
        )

        // Shield Icon
        Box(
            modifier = Modifier
                .size(64.dp)
                .shadow(
                    elevation = 8.dp,
                    shape = CircleShape,
                    ambientColor = Color.Black.copy(alpha = 0.05f),
                    spotColor = Color.Black.copy(alpha = 0.05f)
                )
                .clip(CircleShape)
                .background(Color.White),
            contentAlignment = Alignment.Center
        ) {
            Text("🛡️", fontSize = 32.sp)
        }

        Text(
            text = "Safe, friendly,\nand verified.",
            style = MaterialTheme.typography.displaySmall,
            fontWeight = FontWeight.Black,
            color = CoffeeInk,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(top = CoffeeSpacing.xl, bottom = CoffeeSpacing.md)
        )

        Text(
            text = "We prioritize trust and real connections through verified profiles and community vibes.",
            style = MaterialTheme.typography.bodyLarge,
            color = CoffeeMuted,
            lineHeight = 22.sp,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(bottom = 40.dp)
        )

        // Safety Rows
        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
        ) {
            SafetyFeatureRow(icon = "🔒", text = "Verified Community")
            SafetyFeatureRow(icon = "👥", text = "Shared Mutual Friends")
            SafetyFeatureRow(icon = "❤️", text = "Vibe-Checked Meetups")
        }

        Spacer(modifier = Modifier.weight(1f))
        Spacer(modifier = Modifier.height(40.dp))

        CoffeeButton(
            title = "Sounds Good →",
            onClick = onNext,
            variant = CoffeeButtonVariant.Primary
        )

        Spacer(modifier = Modifier.height(40.dp))
    }
}

// MARK: - Slide 4 (Interests Choice)
@Composable
private fun Slide4View(onNext: () -> Unit) {
    val interests = listOf("Creative", "Walks", "Gaming", "Study", "Food", "Startup", "Music", "Coffee")
    val selectedInterests = remember { mutableStateListOf<String>() }

    val remaining = maxOf(0, 3 - selectedInterests.size)
    val isReady = remaining == 0

    Column(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = CoffeeSpacing.xl)
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.Start
    ) {
        OnboardingProgressBar(
            activeIndex = 2,
            total = 4,
            modifier = Modifier.padding(top = CoffeeSpacing.xl, bottom = 40.dp)
        )

        Text(
            text = "What are you into today?",
            style = MaterialTheme.typography.displaySmall,
            fontWeight = FontWeight.Black,
            color = CoffeeInk,
            modifier = Modifier.padding(bottom = CoffeeSpacing.md)
        )

        Text(
            text = "Select at least 3 to find your vibe.",
            style = MaterialTheme.typography.bodyLarge,
            color = CoffeeMuted,
            modifier = Modifier.padding(bottom = 40.dp)
        )

        // Grid of Interests
        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
        ) {
            for (chunk in interests.chunked(2)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
                ) {
                    chunk.forEach { interest ->
                        InterestPill(
                            title = interest,
                            isSelected = selectedInterests.contains(interest),
                            onClick = {
                                if (selectedInterests.contains(interest)) {
                                    selectedInterests.remove(interest)
                                } else {
                                    selectedInterests.add(interest)
                                }
                            },
                            modifier = Modifier.weight(1f)
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.weight(1f))
        Spacer(modifier = Modifier.height(40.dp))

        CoffeeButton(
            title = if (isReady) "Let's Go" else "Select $remaining more",
            onClick = onNext,
            variant = CoffeeButtonVariant.Primary,
            enabled = isReady,
            height = CoffeeSpacing.primaryButtonHeight
        )

        Spacer(modifier = Modifier.height(40.dp))
    }
}

// MARK: - Slide 5 (Ready Screen)
@Composable
private fun Slide5View(onStartExploring: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = CoffeeSpacing.xl),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.weight(1f))

        // Celebration badge/emoji box
        Box(
            modifier = Modifier
                .size(88.dp)
                .shadow(
                    elevation = 10.dp,
                    shape = RoundedCornerShape(24.dp),
                    ambientColor = Color.Black.copy(alpha = 0.1f),
                    spotColor = Color.Black.copy(alpha = 0.1f)
                )
                .clip(RoundedCornerShape(24.dp))
                .background(CoffeePrimary),
            contentAlignment = Alignment.Center
        ) {
            Text("🎉", fontSize = 40.sp)
        }

        Text(
            text = "You're ready to\njoin the moment.",
            style = MaterialTheme.typography.displaySmall,
            fontWeight = FontWeight.Black,
            color = Color.White,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(top = 32.dp, bottom = CoffeeSpacing.md)
        )

        Text(
            text = "48 meetups happening in your city right now.",
            style = MaterialTheme.typography.bodyLarge,
            color = Color.White.copy(alpha = 0.85f),
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(bottom = 32.dp)
        )

        // Avatar Row Stack
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy((-12).dp)
        ) {
            OnboardingImages.avatars.forEach { avatarUrl ->
                AsyncImage(
                    model = avatarUrl,
                    contentDescription = null,
                    modifier = Modifier
                        .size(CoffeeSpacing.minTouchTarget)
                        .clip(CircleShape)
                        .border(2.dp, Color.White, CircleShape),
                    contentScale = ContentScale.Crop
                )
            }
            Box(
                modifier = Modifier
                    .size(CoffeeSpacing.minTouchTarget)
                    .clip(CircleShape)
                    .background(CoffeePurple.copy(alpha = 0.8f))
                    .border(2.dp, Color.White, CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "+1.2k",
                    style = MaterialTheme.typography.labelSmall,
                    color = Color.White,
                    fontWeight = FontWeight.Bold
                )
            }
        }

        Text(
            text = "JOIN RILEY AND 1,204 OTHERS NEARBY",
            style = MaterialTheme.typography.labelSmall,
            color = Color.White.copy(alpha = 0.8f),
            fontWeight = FontWeight.Black,
            letterSpacing = 1.2.sp,
            modifier = Modifier.padding(top = CoffeeSpacing.md)
        )

        Spacer(modifier = Modifier.weight(1f))

        CoffeeButton(
            title = "Start Exploring",
            onClick = onStartExploring,
            variant = CoffeeButtonVariant.Primary,
            modifier = Modifier.padding(bottom = CoffeeSpacing.md)
        )

        Text(
            text = "NO CREDIT CARD REQUIRED • JOIN FOR FREE",
            style = MaterialTheme.typography.labelSmall,
            color = Color.White.copy(alpha = 0.55f),
            fontWeight = FontWeight.Black,
            letterSpacing = 1.0.sp,
            modifier = Modifier.padding(bottom = 40.dp)
        )
    }
}

// MARK: - Subcomponents

@Composable
private fun GlassmorphicCard(
    modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(24.dp))
            .background(Color.White.copy(alpha = 0.12f))
            .border(
                width = 1.dp,
                color = Color.White.copy(alpha = 0.25f),
                shape = RoundedCornerShape(24.dp)
            )
            .padding(horizontal = CoffeeSpacing.md, vertical = CoffeeSpacing.sm)
    ) {
        content()
    }
}

@Composable
private fun OnboardingProgressBar(activeIndex: Int, total: Int, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
    ) {
        for (i in 0 until total) {
            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(CoffeeSpacing.xxs)
                    .clip(CircleShape)
                    .background(
                        if (i <= activeIndex) CoffeePrimary else CoffeeMuted.copy(alpha = 0.2f)
                    )
            )
        }
    }
}

@Composable
private fun ActivityChip(
    icon: String,
    title: String,
    activeCount: Int,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .shadow(
                elevation = 12.dp,
                shape = RoundedCornerShape(28.dp),
                ambientColor = Color.Black.copy(alpha = 0.04f),
                spotColor = Color.Black.copy(alpha = 0.04f)
            )
            .clip(RoundedCornerShape(28.dp))
            .background(CoffeeSurface)
            .border(1.dp, CoffeeBorder, RoundedCornerShape(28.dp))
            .padding(CoffeeSpacing.md),
        verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm),
        horizontalAlignment = Alignment.Start
    ) {
        Text(text = icon, fontSize = 24.sp)
        Column(verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xxs)) {
            Text(
                text = title,
                style = MaterialTheme.typography.labelMedium,
                color = CoffeeInk,
                fontWeight = FontWeight.Bold
            )
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xxs)
            ) {
                Box(
                    modifier = Modifier
                        .size(6.dp)
                        .clip(CircleShape)
                        .background(CoffeeSuccess)
                )
                Text(
                    text = "$activeCount ACTIVE",
                    style = MaterialTheme.typography.labelSmall.copy(fontSize = 10.sp),
                    color = CoffeeSuccess,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@Composable
private fun SafetyFeatureRow(
    icon: String,
    text: String,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .shadow(
                elevation = 12.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.04f),
                spotColor = Color.Black.copy(alpha = 0.04f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(CoffeeSurface)
            .border(1.dp, CoffeeBorder, RoundedCornerShape(16.dp))
            .padding(CoffeeSpacing.md),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.md)
    ) {
        Text(text = icon, fontSize = 20.sp, modifier = Modifier.width(CoffeeSpacing.xl))
        Text(
            text = text,
            style = MaterialTheme.typography.bodyLarge,
            color = CoffeeInk,
            fontWeight = FontWeight.Medium
        )
    }
}

@Composable
private fun InterestPill(
    title: String,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .shadow(
                elevation = 12.dp,
                shape = RoundedCornerShape(30.dp),
                ambientColor = Color.Black.copy(alpha = 0.04f),
                spotColor = Color.Black.copy(alpha = 0.04f)
            )
            .clip(RoundedCornerShape(30.dp))
            .background(if (isSelected) CoffeePrimary else CoffeeSurface)
            .border(1.dp, if (isSelected) Color.Transparent else CoffeeBorder, RoundedCornerShape(30.dp))
            .clickable(onClick = onClick)
            .padding(vertical = CoffeeSpacing.md),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.bodyLarge,
            fontWeight = FontWeight.Medium,
            color = if (isSelected) Color.White else CoffeeInk
        )
    }
}
