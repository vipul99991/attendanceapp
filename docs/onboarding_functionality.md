# Onboarding Functionality Documentation

This document provides comprehensive documentation for the AttendanceApp's onboarding functionality, which guides new users through the initial setup and familiarization process to ensure a successful start with the application.

## Overview

The onboarding functionality is designed to provide a seamless, engaging, and educational introduction to the AttendanceApp for new users. It combines informative walkthroughs, interactive tutorials, and progressive feature disclosure to ensure users understand the application's capabilities and value proposition while collecting essential information needed for personalized experiences.

## Onboarding Goals

### User Education
Introduce users to the core features and benefits of the AttendanceApp through guided exploration.

#### Objectives
1. **Feature Awareness**: Help users discover key application features
2. **Value Communication**: Clearly communicate the benefits of using the app
3. **Confidence Building**: Build user confidence in using the application
4. **Engagement Creation**: Create positive first impressions that encourage continued use

### Data Collection
Gather essential information needed for personalized user experiences while respecting privacy.

#### Requirements
1. **Minimal Data**: Collect only necessary information for initial setup
2. **Privacy Respect**: Clearly communicate data usage and protection
3. **User Control**: Give users control over their information
4. **Secure Storage**: Protect collected data with appropriate security measures

### Feature Discovery
Help users discover and understand how to use key functionalities.

#### Focus Areas
1. **Time Tracking**: Demonstrate clock in/out functionality
2. **Location Verification**: Explain GPS-based attendance verification
3. **Biometric Security**: Showcase selfie verification for secure attendance
4. **Leave Management**: Illustrate leave request and approval workflows
5. **Payroll Access**: Show how users can access payslips and compensation details
6. **Profile Management**: Guide users through personal information setup

## Onboarding Flow

### Welcome Screen
The initial screen that greets users and sets expectations for the onboarding experience.

#### Key Elements
1. **Brand Introduction**: Clear application branding and value proposition
2. **Skip Option**: Allow experienced users to bypass onboarding
3. **Progress Indication**: Visual representation of onboarding steps
4. **Engagement Hook**: Compelling reason to continue

#### Design Considerations
- **Minimalist Design**: Minimalist design to avoid overwhelming new users
- **Clear Value Proposition**: Clear value proposition highlighting key benefits
- **Visually Appealing**: Visually appealing graphics or animations
- **Responsive Layout**: Responsive layout for all device sizes

#### Implementation
```dart
class WelcomeScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const WelcomeScreen({super.key, this.onComplete});
  
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  bool showLoading = false;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    // Auto start loading after welcome animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showLoading = true;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: SafeArea(
              child: showLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo during loading
                          Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  FontAwesomeIcons.userClock,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 40,
                                ),
                              )
                              .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true),
                              )
                              .scale(
                                begin: const Offset(1.0, 1.0),
                                end: const Offset(1.1, 1.1),
                                duration: const Duration(seconds: 1),
                              ),

                          const SizedBox(height: 48),

                          LoadingIndicator(
                            onComplete: () async {
                              // Mark onboarding as completed
                              await OnboardingService.markOnboardingCompleted();
                              
                              if (widget.onComplete != null) {
                                widget.onComplete!();
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Animated background elements
                                  Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Rotating circles
                                          AnimatedBuilder(
                                            animation: _rotationController,
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle:
                                                    _rotationController.value *
                                                    2 *
                                                    3.14159,
                                                child: Container(
                                                  width: 200,
                                                  height: 200,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white.withOpacity(
                                                        0.1,
                                                      ),
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                          AnimatedBuilder(
                                            animation: _rotationController,
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle:
                                                    -_rotationController.value *
                                                    2 *
                                                    3.14159,
                                                child: Container(
                                                  width: 150,
                                                  height: 150,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white.withOpacity(
                                                        0.1,
                                                      ),
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                          // Main logo
                                          AnimatedBuilder(
                                            animation: _pulseController,
                                            builder: (context, child) {
                                              return Transform.scale(
                                                scale:
                                                    1.0 +
                                                    (_pulseController.value * 0.1),
                                                child: Container(
                                                  width: 120,
                                                  height: 120,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(
                                                          0.2,
                                                        ),
                                                        blurRadius: 30,
                                                        offset: const Offset(0, 15),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    FontAwesomeIcons.userClock,
                                                    color: Theme.of(context).colorScheme.primary,
                                                    size: 60,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      )
                                      .animate()
                                      .fadeIn(
                                        duration: const Duration(milliseconds: 800),
                                      )
                                      .scale(
                                        begin: const Offset(0.5, 0.5),
                                        duration: const Duration(milliseconds: 800),
                                        curve: Curves.elasticOut,
                                      ),

                                  const SizedBox(height: 48),

                                  // App title
                                  Text(
                                        'AttendanceApp',
                                        style: GoogleFonts.poppins(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.2,
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(
                                        delay: const Duration(milliseconds: 400),
                                        duration: const Duration(milliseconds: 600),
                                      )
                                      .slideY(
                                        begin: 0.3,
                                        duration: const Duration(milliseconds: 600),
                                        curve: Curves.easeOut,
                                      ),

                                  const SizedBox(height: 16),

                                  // Subtitle
                                  Text(
                                        'Smart Time & Attendance Management',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                      .animate()
                                      .fadeIn(
                                        delay: const Duration(milliseconds: 600),
                                        duration: const Duration(milliseconds: 600),
                                      )
                                      .slideY(
                                        begin: 0.3,
                                        duration: const Duration(milliseconds: 600),
                                        curve: Curves.easeOut,
                                      ),

                                  const SizedBox(height: 48),

                                  // Feature icons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildFeatureIcon(
                                        FontAwesomeIcons.clock,
                                        'Time Tracking',
                                        0,
                                      ),
                                      const SizedBox(width: 40),
                                      _buildFeatureIcon(
                                        FontAwesomeIcons.mapMarkerAlt,
                                        'GPS Punch',
                                        200,
                                      ),
                                      const SizedBox(width: 40),
                                      _buildFeatureIcon(
                                        FontAwesomeIcons.camera,
                                        'Selfie Verify',
                                        400,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Skip button at the top right
                        Positioned(
                          top: 20,
                          right: 20,
                          child: TextButton(
                            onPressed: () async {
                              // Mark onboarding as completed
                              await OnboardingService.markOnboardingCompleted();
                              
                              if (widget.onComplete != null) {
                                widget.onComplete!();
                              }
                            },
                            child: Text(
                              'Skip',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        // Floating action elements at the bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                // Animated dots indicator
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(3, (index) {
                                    return Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(0.6),
                                          ),
                                        )
                                        .animate(
                                          onPlay: (controller) => controller.repeat(),
                                        )
                                        .fadeIn(
                                          delay: Duration(
                                            milliseconds: index * 300 + 1000,
                                          ),
                                          duration: const Duration(milliseconds: 800),
                                        )
                                        .then(
                                          delay: const Duration(milliseconds: 400),
                                        )
                                        .fadeOut(
                                          duration: const Duration(milliseconds: 800),
                                        );
                                  }),
                                ),

                                const SizedBox(height: 24),

                                // Swipe up indicator
                                Column(
                                  children: [
                                    Icon(
                                          Icons.keyboard_arrow_up,
                                          color: Colors.white.withOpacity(0.7),
                                          size: 24,
                                        )
                                        .animate(
                                          onPlay: (controller) =>
                                              controller.repeat(reverse: true),
                                        )
                                        .moveY(
                                          begin: 0,
                                          end: -10,
                                          duration: const Duration(seconds: 1),
                                        ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Swipe up to continue',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ).animate().fadeIn(
                                  delay: const Duration(milliseconds: 2000),
                                  duration: const Duration(milliseconds: 800),
                                ),
                              ],
                            ),
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
  
  Widget _buildFeatureIcon(IconData icon, String label, int delay) {
    return Column(
      children: [
        Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: 800 + delay),
              duration: const Duration(milliseconds: 600),
            )
            .scale(
              begin: const Offset(0.5, 0.5),
              delay: Duration(milliseconds: 800 + delay),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
            ),

        const SizedBox(height: 8),

        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(
          delay: Duration(milliseconds: 1000 + delay),
          duration: const Duration(milliseconds: 600),
        ),
      ],
    );
  }
}
```

### Feature Showcase
A series of screens that highlight key application features through visual demonstrations.

#### Screens Covered
1. **Time Tracking**: Demonstrate clock in/out functionality
2. **Location Verification**: Explain GPS-based attendance verification
3. **Biometric Security**: Showcase selfie verification for secure attendance
4. **Leave Management**: Illustrate leave request and approval workflows
5. **Payroll Access**: Show how users can access payslips and compensation details
6. **Profile Management**: Guide users through personal information setup

#### Interaction Patterns
- **Swipe Navigation**: Horizontal swiping between feature screens
- **Auto-Advance**: Timed progression with manual override
- **Interactive Elements**: Clickable areas that demonstrate functionality
- **Progressive Disclosure**: Reveal information gradually to avoid overload

#### Implementation
```dart
class FeatureShowcaseScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const FeatureShowcaseScreen({super.key, this.onComplete});
  
  @override
  State<FeatureShowcaseScreen> createState() => _FeatureShowcaseScreenState();
}

class _FeatureShowcaseScreenState extends State<FeatureShowcaseScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _animationController;
  
  static const List<Feature> _features = [
    Feature(
      title: 'Time Tracking',
      description: 'Easily clock in and out with just one tap',
      icon: FontAwesomeIcons.clock,
      color: Color(0xFF6366F1),
    ),
    Feature(
      title: 'Location Verification',
      description: 'Verify your location with GPS for accurate attendance',
      icon: FontAwesomeIcons.mapMarkerAlt,
      color: Color(0xFF8B5CF6),
    ),
    Feature(
      title: 'Biometric Security',
      description: 'Secure your attendance with facial recognition',
      icon: FontAwesomeIcons.camera,
      color: Color(0xFFA855F7),
    ),
    Feature(
      title: 'Leave Management',
      description: 'Request and track leave with our intuitive system',
      icon: FontAwesomeIcons.calendarDays,
      color: Color(0xFFEC4899),
    ),
    Feature(
      title: 'Payroll Access',
      description: 'View payslips and compensation details anytime',
      icon: FontAwesomeIcons.moneyBill,
      color: Color(0xFFF59E0B),
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Progress indicator
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Go back or skip
                            if (widget.onComplete != null) {
                              widget.onComplete!();
                            }
                          },
                          child: Text(
                            'Skip',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(_features.length, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.4),
                              ),
                            );
                          }),
                        ),
                        TextButton(
                          onPressed: () {
                            // Go to next screen or complete onboarding
                            if (_currentPage < _features.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              if (widget.onComplete != null) {
                                widget.onComplete!();
                              }
                            }
                          },
                          child: Text(
                            _currentPage < _features.length - 1 ? 'Next' : 'Done',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Feature showcase
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _features.length,
                      itemBuilder: (context, index) {
                        final feature = _features[index];
                        return _buildFeaturePage(feature);
                      },
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
  
  Widget _buildFeaturePage(Feature feature) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Feature icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: feature.color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: feature.color.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Icon(
              feature.icon,
              color: Colors.white,
              size: 60,
            ),
          ).animate().fadeIn(duration: 600.ms).shake(
            delay: 200.ms,
            hz: 1.2,
            offset: const Offset(5, 0),
          ),
          
          const SizedBox(height: 48),
          
          // Feature title
          Text(
            feature.title,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ).animate().fadeIn(
            delay: 400.ms,
            duration: 600.ms,
          ).slideY(
            begin: 0.3,
            duration: 600.ms,
            curve: Curves.easeOut,
          ),
          
          const SizedBox(height: 16),
          
          // Feature description
          Text(
            feature.description,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            delay: 600.ms,
            duration: 600.ms,
          ).slideY(
            begin: 0.3,
            duration: 600.ms,
            curve: Curves.easeOut,
          ),
          
          const SizedBox(height: 48),
          
          // Demo animation
          _buildDemoAnimation(feature),
        ],
      ),
    );
  }
  
  Widget _buildDemoAnimation(Feature feature) {
    switch (feature.title) {
      case 'Time Tracking':
        return _buildClockAnimation();
      case 'Location Verification':
        return _buildLocationAnimation();
      case 'Biometric Security':
        return _buildBiometricAnimation();
      case 'Leave Management':
        return _buildLeaveAnimation();
      case 'Payroll Access':
        return _buildPayrollAnimation();
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildClockAnimation() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hour hand
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Minute hand
          Transform.rotate(
            angle: 3.14159 / 3,
            child: Container(
              width: 3,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
          // Second hand
          Transform.rotate(
            angle: 3.14159 / 6,
            child: Container(
              width: 2,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          // Center dot
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(period: const Duration(seconds: 10)),
    ).rotate(
      begin: 0,
      end: 3.14159 * 2,
      duration: const Duration(seconds: 10),
      curve: Curves.linear,
    );
  }
  
  Widget _buildLocationAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer circle
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        // Middle circle
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        // Inner circle (user location)
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            FontAwesomeIcons.locationDot,
            color: Colors.white,
            size: 24,
          ),
        ),
        // Accuracy ring
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.5),
              width: 2,
            ),
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        ).scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.2, 1.2),
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
        ),
      ],
    );
  }
  
  Widget _buildBiometricAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Face outline
        Container(
          width: 120,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(60),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
        ),
        // Eyes
        Positioned(
          top: 50,
          left: 30,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: 30,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Smile
        Positioned(
          bottom: 40,
          child: Container(
            width: 60,
            height: 30,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
        ),
        // Scan line
        Container(
          width: 120,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFF6366F1),
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(),
        ).moveY(
          begin: -75,
          end: 75,
          duration: const Duration(seconds: 2),
          curve: Curves.linear,
        ),
      ],
    );
  }
  
  Widget _buildLeaveAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Calendar
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Calendar header
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Text(
                    'June 2023',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // Calendar days
              Expanded(
                child: GridView.count(
                  crossAxisCount: 7,
                  children: List.generate(28, (index) {
                    final day = index + 1;
                    final isWeekend = day % 7 == 0 || day % 7 == 6;
                    final isLeave = day >= 15 && day <= 17;
                    
                    return Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isLeave
                            ? const Color(0xFFEF4444).withOpacity(0.3)
                            : isWeekend
                                ? Colors.white.withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          day.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: isLeave
                                ? const Color(0xFFEF4444)
                                : Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        // Leave request icon
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FontAwesomeIcons.plus,
              color: Colors.white,
              size: 20,
            ),
          ).animate().fadeIn(duration: 800.ms).shake(
            delay: 1000.ms,
            hz: 1.2,
            offset: const Offset(5, 0),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPayrollAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Payslip
        Container(
          width: 150,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Center(
                  child: Text(
                    'PAYSLIP',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Period: Jun 2023',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gross Pay:',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            '₹45,000',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Net Pay:',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            '₹38,500',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Download icon
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FontAwesomeIcons.download,
              color: Colors.white,
              size: 20,
            ),
          ).animate().fadeIn(duration: 800.ms).shake(
            delay: 1000.ms,
            hz: 1.2,
            offset: const Offset(5, 0),
          ),
        ),
      ],
    );
  }
}

class Feature {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  
  const Feature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
```

### Account Setup
Guide users through creating their account and configuring initial preferences.

#### Required Information
- **Personal Details**: Name, contact information, demographics
- **Employment Information**: Organization, role, department
- **Security Preferences**: Authentication methods, biometric enrollment
- **Notification Settings**: Communication preferences

#### Validation Process
- **Real-time Validation**: Immediate feedback on input correctness
- **Progressive Completion**: Allow partial completion with follow-up prompts
- **Data Integrity**: Ensure required fields are completed before proceeding
- **Privacy Assurance**: Clear communication about data usage and protection

#### Implementation
```dart
class AccountSetupScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const AccountSetupScreen({super.key, this.onComplete});
  
  @override
  State<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends State<AccountSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeIdController = TextEditingController();
  
  bool _isSubmitting = false;
  String? _errorMessage;
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }
  
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
        _errorMessage = null;
      });
      
      try {
        // Validate employee ID with backend
        final isValidEmployee = await EmployeeService.validateEmployeeId(
          _employeeIdController.text.trim(),
        );
        
        if (!isValidEmployee) {
          setState(() {
            _errorMessage = 'Invalid employee ID. Please check and try again.';
            _isSubmitting = false;
          });
          return;
        }
        
        // Create employee profile
        final employee = Employee(
          employeeId: _employeeIdController.text.trim(),
          legalName: LegalName(
            first: _nameController.text.trim().split(' ').first,
            last: _nameController.text.trim().split(' ').last,
          ),
          contactInfo: ContactInfo(
            workEmail: _emailController.text.trim(),
            mobilePhone: _phoneController.text.trim(),
          ),
          // Other required fields with default values
          status: EmployeeStatus.active,
          employmentDetails: EmploymentDetails(
            hireDate: DateTime.now(),
            employmentType: EmploymentType.fullTime,
            designation: 'Employee',
            organization: Organization(
              companyId: 'DEFAULT_COMPANY',
              businessUnit: 'DEFAULT_UNIT',
              department: 'DEFAULT_DEPARTMENT',
              costCenter: 'DEFAULT_COST_CENTER',
            ),
            assignments: [],
            workMode: WorkMode.hybrid,
          ),
          attendanceSettings: AttendanceSettings(
            defaultSiteId: 'DEFAULT_SITE',
            defaultShiftTemplateId: 'DEFAULT_SHIFT',
            allowedPunchMethods: [PunchMethod.geo, PunchMethod.kioskPin],
            policyPackId: 'DEFAULT_POLICY',
          ),
          leaveSettings: LeaveSettings(
            leavePolicyId: 'DEFAULT_LEAVE_POLICY',
            leaveBalances: {},
            holidayCalendarId: 'DEFAULT_HOLIDAY_CALENDAR',
            weeklyOff: ['Saturday', 'Sunday'],
          ),
          payrollDetails: PayrollDetails(
            payType: PayType.salary,
            basePay: 0.0,
            currency: 'INR',
            payCycle: PayCycle.monthly,
          ),
          workAuthorization: WorkAuthorization(
            citizenshipCountry: 'India',
          ),
          securitySettings: SecuritySettings(
            registeredDevices: [],
            mfaMethods: [],
          ),
          emergencyContacts: [],
          documents: [],
          personalPreferences: PersonalPreferences(
            skills: [],
            languages: [],
          ),
          privacySettings: PrivacySettings(
            consents: [],
          ),
          systemInfo: SystemInfo(
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        // Save employee profile
        await EmployeeService.createEmployee(employee);
        
        // Mark onboarding as completed
        await OnboardingService.markOnboardingCompleted();
        
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to create account. Please try again.';
          _isSubmitting = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Account Setup',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to AttendanceApp!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please complete your account setup to get started.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      if (value.trim().split(' ').length < 2) {
                        return 'Please enter both first and last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Work Email',
                      hintText: 'Enter your work email address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your work email';
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Phone',
                      hintText: 'Enter your mobile phone number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile phone number';
                      }
                      // Simple phone number validation
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Employee ID field
                  TextFormField(
                    controller: _employeeIdController,
                    decoration: InputDecoration(
                      labelText: 'Employee ID',
                      hintText: 'Enter your employee ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your employee ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              'Complete Setup',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
}
```

### Tutorial Walkthrough
Interactive tutorials that allow users to practice key workflows in a safe environment.

#### Tutorials Included
1. **Clocking In**: Step-by-step guide to clock in process
2. **Requesting Leave**: Complete workflow for leave submission
3. **Updating Profile**: How to modify personal information
4. **Accessing Payroll**: Navigating to payslips and compensation details

#### Tutorial Mechanics
- **Simulated Environment**: Safe space to practice without consequences
- **Guided Instructions**: Clear step-by-step directions
- **Immediate Feedback**: Real-time correction of mistakes
- **Completion Rewards**: Recognition for tutorial completion

#### Implementation
```dart
class TutorialWalkthroughScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const TutorialWalkthroughScreen({super.key, this.onComplete});
  
  @override
  State<TutorialWalkthroughScreen> createState() => _TutorialWalkthroughScreenState();
}

class _TutorialWalkthroughScreenState extends State<TutorialWalkthroughScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _highlightController;
  
  static const List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      title: 'Clocking In',
      description: 'Learn how to clock in to start your workday',
      icon: FontAwesomeIcons.clock,
      steps: [
        'Tap the CLOCK IN button on your dashboard',
        'Allow location access when prompted',
        'Take a selfie for biometric verification',
        'Confirm your clock in time and location',
      ],
    ),
    TutorialStep(
      title: 'Requesting Leave',
      description: 'Discover how to submit leave requests',
      icon: FontAwesomeIcons.calendarDays,
      steps: [
        'Navigate to the Leave tab',
        'Tap the "Request Leave" button',
        'Select leave type and dates',
        'Add any notes or attachments',
        'Submit your request for approval',
      ],
    ),
    TutorialStep(
      title: 'Updating Profile',
      description: 'Manage your personal information',
      icon: FontAwesomeIcons.user,
      steps: [
        'Go to the Profile tab',
        'Tap "Edit Profile" to make changes',
        'Update your contact information',
        'Save your changes when finished',
      ],
    ),
    TutorialStep(
      title: 'Accessing Payroll',
      description: 'View your payslips and compensation details',
      icon: FontAwesomeIcons.moneyBill,
      steps: [
        'Visit the Pay tab',
        'Browse your payslip history',
        'Download payslips as PDF documents',
        'View detailed compensation breakdown',
      ],
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _highlightController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Progress indicator
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Skip tutorial
                            if (widget.onComplete != null) {
                              widget.onComplete!();
                            }
                          },
                          child: Text(
                            'Skip',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(_tutorialSteps.length, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.4),
                              ),
                            );
                          }),
                        ),
                        TextButton(
                          onPressed: () {
                            // Complete tutorial or go to next step
                            if (_currentPage < _tutorialSteps.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              // Mark tutorial as completed
                              OnboardingService.markTutorialCompleted();
                              
                              if (widget.onComplete != null) {
                                widget.onComplete!();
                              }
                            }
                          },
                          child: Text(
                            _currentPage < _tutorialSteps.length - 1 ? 'Next' : 'Done',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tutorial content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _tutorialSteps.length,
                      itemBuilder: (context, index) {
                        final step = _tutorialSteps[index];
                        return _buildTutorialPage(step);
                      },
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
  
  Widget _buildTutorialPage(TutorialStep step) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Step icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              step.icon,
              color: Colors.white,
              size: 48,
            ),
          ).animate().fadeIn(duration: 600.ms).shake(
            delay: 200.ms,
            hz: 1.2,
            offset: const Offset(5, 0),
          ),
          
          const SizedBox(height: 32),
          
          // Step title
          Text(
            step.title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ).animate().fadeIn(
            delay: 400.ms,
            duration: 600.ms,
          ).slideY(
            begin: 0.3,
            duration: 600.ms,
            curve: Curves.easeOut,
          ),
          
          const SizedBox(height: 16),
          
          // Step description
          Text(
            step.description,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            delay: 600.ms,
            duration: 600.ms,
          ).slideY(
            begin: 0.3,
            duration: 600.ms,
            curve: Curves.easeOut,
          ),
          
          const SizedBox(height: 32),
          
          // Step instructions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Steps:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(step.steps.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ).animate().fadeIn(
                          delay: Duration(milliseconds: 800 + (index * 200)),
                          duration: const Duration(milliseconds: 400),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            step.steps[index],
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ).animate().fadeIn(
                            delay: Duration(milliseconds: 1000 + (index * 200)),
                            duration: const Duration(milliseconds: 400),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Interactive demo button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Launch interactive demo for this step
                _launchInteractiveDemo(step.title);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                'Try It Now',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 2000),
            duration: const Duration(milliseconds: 600),
          ),
        ],
      ),
    );
  }
  
  void _launchInteractiveDemo(String tutorialTitle) {
    // Launch interactive demo based on tutorial title
    switch (tutorialTitle) {
      case 'Clocking In':
        // Show simulated clock in screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SimulatedClockInScreen(),
          ),
        );
        break;
      case 'Requesting Leave':
        // Show simulated leave request screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SimulatedLeaveRequestScreen(),
          ),
        );
        break;
      case 'Updating Profile':
        // Show simulated profile update screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SimulatedProfileUpdateScreen(),
          ),
        );
        break;
      case 'Accessing Payroll':
        // Show simulated payroll access screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SimulatedPayrollScreen(),
          ),
        );
        break;
    }
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final List<String> steps;
  
  const TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.steps,
  });
}

// Simulated screens for interactive demos
class SimulatedClockInScreen extends StatelessWidget {
  const SimulatedClockInScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Simulated Clock In',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is a simulated clock in screen for tutorial purposes.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Back to Tutorial',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimulatedLeaveRequestScreen extends StatelessWidget {
  const SimulatedLeaveRequestScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Simulated Leave Request',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is a simulated leave request screen for tutorial purposes.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Back to Tutorial',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimulatedProfileUpdateScreen extends StatelessWidget {
  const SimulatedProfileUpdateScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Simulated Profile Update',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is a simulated profile update screen for tutorial purposes.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Back to Tutorial',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimulatedPayrollScreen extends StatelessWidget {
  const SimulatedPayrollScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Simulated Payroll Access',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is a simulated payroll access screen for tutorial purposes.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Back to Tutorial',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Personalization
Allow users to customize their experience based on preferences and role.

#### Customization Options
- **Theme Selection**: Light/dark mode preferences
- **Notification Preferences**: Frequency and type of communications
- **Dashboard Layout**: Arrangement of key metrics and quick actions
- **Feature Preferences**: Selection of most-used features for quick access

#### Implementation
- **Preference Profiles**: Save user preferences for future sessions
- **Adaptive Interface**: Modify UI based on user selections
- **Default Templates**: Pre-configured options for common roles
- **Preview Capabilities**: Show how changes will look before applying

#### Implementation
```dart
class PersonalizationScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const PersonalizationScreen({super.key, this.onComplete});
  
  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  ThemeMode _selectedTheme = ThemeMode.system;
  bool _enablePushNotifications = true;
  bool _enableEmailNotifications = true;
  bool _enableSmsNotifications = true;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Personalize Your Experience',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make AttendanceApp yours',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customize your experience to match your preferences.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Theme selection
                _buildSectionHeader('Appearance'),
                const SizedBox(height: 16),
                _buildThemeSelector(themeManager),
                const SizedBox(height: 32),
                
                // Notification preferences
                _buildSectionHeader('Notifications'),
                const SizedBox(height: 16),
                _buildNotificationOption(
                  'Push Notifications',
                  'Receive notifications on your device',
                  _enablePushNotifications,
                  (value) => setState(() => _enablePushNotifications = value),
                ),
                const SizedBox(height: 16),
                _buildNotificationOption(
                  'Email Notifications',
                  'Receive notifications via email',
                  _enableEmailNotifications,
                  (value) => setState(() => _enableEmailNotifications = value),
                ),
                const SizedBox(height: 16),
                _buildNotificationOption(
                  'SMS Notifications',
                  'Receive notifications via SMS',
                  _enableSmsNotifications,
                  (value) => setState(() => _enableSmsNotifications = value),
                ),
                const SizedBox(height: 32),
                
                // Dashboard layout
                _buildSectionHeader('Dashboard Layout'),
                const SizedBox(height: 16),
                _buildDashboardLayoutOptions(),
                const SizedBox(height: 32),
                
                // Feature preferences
                _buildSectionHeader('Quick Access'),
                const SizedBox(height: 16),
                _buildFeaturePreferences(),
                const SizedBox(height: 48),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _savePreferences,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Save Preferences',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
  
  Widget _buildThemeSelector(ThemeManager themeManager) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  'System Default',
                  ThemeMode.system,
                  themeManager.themeMode == ThemeMode.system,
                  () => themeManager.setThemeMode(ThemeMode.system),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeOption(
                  'Light Mode',
                  ThemeMode.light,
                  themeManager.themeMode == ThemeMode.light,
                  () => themeManager.setThemeMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeOption(
                  'Dark Mode',
                  ThemeMode.dark,
                  themeManager.themeMode == ThemeMode.dark,
                  () => themeManager.setThemeMode(ThemeMode.dark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildThemeOption(
    String label,
    ThemeMode mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              mode == ThemeMode.system
                  ? Icons.auto_mode
                  : mode == ThemeMode.light
                      ? Icons.light_mode
                      : Icons.dark_mode,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotificationOption(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDashboardLayoutOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Coming soon: Customize your dashboard layout',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select which widgets to display and arrange them to your preference.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeaturePreferences() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Coming soon: Select your favorite features',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose which features to display in your quick access toolbar.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _savePreferences() async {
    // Save preferences to persistent storage
    await OnboardingService.savePersonalizationPreferences(
      themeMode: _selectedTheme,
      pushNotifications: _enablePushNotifications,
      emailNotifications: _enableEmailNotifications,
      smsNotifications: _enableSmsNotifications,
    );
    
    // Mark personalization as completed
    await OnboardingService.markPersonalizationCompleted();
    
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }
}
```

## Progressive Disclosure

### Feature Rollout
Gradually introduce advanced features as users become more familiar with basics.

#### Phased Approach
1. **Core Features**: Essential time tracking and profile management
2. **Intermediate Features**: Leave management and basic reporting
3. **Advanced Features**: Analytics, integrations, and administrative tools

#### Timing Mechanisms
- **Usage-Based Triggers**: Introduce features after specific usage milestones
- **Time-Based Triggers**: Gradual rollout over weeks or months
- **Skill-Based Triggers**: Unlock features after demonstrating competency
- **Interest-Based Triggers**: Show features based on observed user interests

#### Implementation
```dart
class FeatureDiscoveryService {
  static const String _featureDiscoveryKey = 'feature_discovery_progress';
  
  // Track user's feature discovery progress
  static Future<void> trackFeatureViewed(String featureId) async {
    final prefs = await SharedPreferences.getInstance();
    final discoveryData = prefs.getString(_featureDiscoveryKey) ?? '{}';
    final discoveryMap = jsonDecode(discoveryData) as Map<String, dynamic>;
    
    discoveryMap[featureId] = {
      'viewedAt': DateTime.now().toIso8601String(),
      'viewCount': (discoveryMap[featureId]?['viewCount'] ?? 0) + 1,
    };
    
    await prefs.setString(
      _featureDiscoveryKey,
      jsonEncode(discoveryMap),
    );
  }
  
  // Determine if a feature should be shown to the user
  static Future<bool> shouldShowFeature(String featureId) async {
    final prefs = await SharedPreferences.getInstance();
    final discoveryData = prefs.getString(_featureDiscoveryKey) ?? '{}';
    final discoveryMap = jsonDecode(discoveryData) as Map<String, dynamic>;
    
    // Check if feature has been viewed before
    final featureData = discoveryMap[featureId];
    if (featureData == null) {
      // New feature, show it
      return true;
    }
    
    // Check view count and timing
    final viewCount = featureData['viewCount'] as int? ?? 0;
    final viewedAt = DateTime.parse(featureData['viewedAt'] as String);
    
    // Don't show the same feature tip more than 3 times
    if (viewCount >= 3) {
      return false;
    }
    
    // Don't show feature tips too frequently
    final daysSinceLastView = DateTime.now().difference(viewedAt).inDays;
    if (daysSinceLastView < 7) {
      return false;
    }
    
    return true;
  }
  
  // Get list of features the user should be introduced to
  static Future<List<String>> getRecommendedFeatures() async {
    final prefs = await SharedPreferences.getInstance();
    final discoveryData = prefs.getString(_featureDiscoveryKey) ?? '{}';
    final discoveryMap = jsonDecode(discoveryData) as Map<String, dynamic>;
    
    // Define feature progression
    final featureProgression = [
      'clock_in_out',
      'leave_requests',
      'payroll_access',
      'profile_management',
      'advanced_reporting',
      'team_management',
      'admin_tools',
    ];
    
    // Filter features based on user's progress
    final viewedFeatures = discoveryMap.keys.toList();
    final recommendedFeatures = <String>[];
    
    for (final feature in featureProgression) {
      if (!viewedFeatures.contains(feature)) {
        recommendedFeatures.add(feature);
      }
    }
    
    return recommendedFeatures;
  }
  
  // Mark onboarding as completed when all core features are discovered
  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final discoveryData = prefs.getString(_featureDiscoveryKey) ?? '{}';
    final discoveryMap = jsonDecode(discoveryData) as Map<String, dynamic>;
    
    // Core features that must be discovered
    final coreFeatures = [
      'clock_in_out',
      'leave_requests',
      'payroll_access',
      'profile_management',
    ];
    
    // Check if all core features have been viewed
    for (final feature in coreFeatures) {
      if (!discoveryMap.containsKey(feature)) {
        return false;
      }
    }
    
    return true;
  }
}
```

### Contextual Help
Provide just-in-time assistance when users encounter new or complex features.

#### Help Delivery
- **Tooltips**: Brief explanations on hover or tap
- **Overlay Guides**: Step-by-step walkthroughs for complex workflows
- **Video Tutorials**: Visual demonstrations of key processes
- **FAQ Integration**: Easy access to common questions and answers

#### Personalization
- **Learning History**: Remember previously viewed help topics
- **Role-Based Help**: Tailor assistance to user's role and permissions
- **Usage Patterns**: Anticipate needs based on behavior analysis
- **Feedback Loop**: Continuously improve help based on user interactions

#### Implementation
```dart
class ContextualHelpService {
  static const String _helpViewsKey = 'help_views';
  
  // Show contextual help for a specific feature
  static Future<void> showHelp(BuildContext context, String featureId) async {
    // Track help view
    await _trackHelpView(featureId);
    
    // Show appropriate help based on feature
    switch (featureId) {
      case 'clock_in_out':
        await _showClockInOutHelp(context);
        break;
      case 'leave_requests':
        await _showLeaveRequestsHelp(context);
        break;
      case 'payroll_access':
        await _showPayrollAccessHelp(context);
        break;
      case 'profile_management':
        await _showProfileManagementHelp(context);
        break;
      default:
        await _showGenericHelp(context, featureId);
    }
  }
  
  // Track help view for analytics
  static Future<void> _trackHelpView(String featureId) async {
    final prefs = await SharedPreferences.getInstance();
    final helpViewsData = prefs.getString(_helpViewsKey) ?? '[]';
    final helpViews = List<String>.from(jsonDecode(helpViewsData));
    
    helpViews.add('$featureId:${DateTime.now().toIso8601String()}');
    
    // Keep only last 100 help views
    if (helpViews.length > 100) {
      helpViews.removeRange(0, helpViews.length - 100);
    }
    
    await prefs.setString(_helpViewsKey, jsonEncode(helpViews));
  }
  
  // Show clock in/out help
  static Future<void> _showClockInOutHelp(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Clock In/Out Help',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to Clock In:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Tap the CLOCK IN button on your dashboard\n'
                  '2. Allow location access when prompted\n'
                  '3. Take a selfie for biometric verification\n'
                  '4. Confirm your clock in time and location',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'How to Clock Out:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Tap the CLOCK OUT button on your dashboard\n'
                  '2. Allow location access when prompted\n'
                  '3. Take a selfie for biometric verification\n'
                  '4. Confirm your clock out time and location',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got It',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Show leave requests help
  static Future<void> _showLeaveRequestsHelp(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Leave Requests Help',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to Request Leave:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Navigate to the Leave tab\n'
                  '2. Tap the "Request Leave" button\n'
                  '3. Select leave type and dates\n'
                  '4. Add any notes or attachments\n'
                  '5. Submit your request for approval',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Checking Leave Balance:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Go to the Leave tab\n'
                  '2. View your current leave balances\n'
                  '3. See upcoming approved leaves\n'
                  '4. Check leave history',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got It',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Show payroll access help
  static Future<void> _showPayrollAccessHelp(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Payroll Access Help',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accessing Payslips:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Visit the Pay tab\n'
                  '2. Browse your payslip history\n'
                  '3. Download payslips as PDF documents\n'
                  '4. View detailed compensation breakdown',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Viewing Compensation Details:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Go to the Pay tab\n'
                  '2. Tap "Compensation Details"\n'
                  '3. View your salary structure\n'
                  '4. See bonus and allowance information',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got It',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Show profile management help
  static Future<void> _showProfileManagementHelp(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Profile Management Help',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Updating Your Profile:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Go to the Profile tab\n'
                  '2. Tap "Edit Profile" to make changes\n'
                  '3. Update your contact information\n'
                  '4. Save your changes when finished',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Managing Documents:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Visit the Profile tab\n'
                  '2. Tap "Documents" to view your documents\n'
                  '3. Upload new documents when needed\n'
                  '4. Download existing documents',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got It',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Show generic help
  static Future<void> _showGenericHelp(BuildContext context, String featureId) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Help',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Help information for $featureId is not yet available.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
```

## User Experience Principles

### Simplicity
Maintain a clean, uncluttered interface that focuses on essential information.

#### Implementation
- **Minimal Text**: Use concise, action-oriented language
- **Visual Hierarchy**: Clear organization of information importance
- **Consistent Patterns**: Familiar interaction models throughout
- **Progressive Complexity**: Start simple and add complexity gradually

### Engagement
Create an enjoyable onboarding experience that encourages continued use.

#### Techniques
- **Gamification**: Reward systems for completing onboarding steps
- **Personal Touch**: Use user's name and personalize content
- **Storytelling**: Frame features within relatable scenarios
- **Interactive Elements**: Engage users through hands-on activities

### Accessibility
Ensure the onboarding experience is usable by people with diverse abilities.

#### Standards
- **WCAG Compliance**: Meet Level AA accessibility standards
- **Screen Reader Support**: Full compatibility with assistive technologies
- **Keyboard Navigation**: Complete functionality without mouse/touch
- **High Contrast Mode**: Support for visually impaired users

### Responsiveness
Provide a seamless experience across all device types and orientations.

#### Adaptations
- **Flexible Layouts**: Adjust to different screen sizes and aspect ratios
- **Touch Optimization**: Appropriate sizing for touch interactions
- **Orientation Awareness**: Different layouts for portrait and landscape
- **Input Method Diversity**: Support for touch, mouse, keyboard, and voice

## Data Management

### User Preferences
Store and manage user preferences to maintain consistent experiences.

#### Storage Strategy
- **Local Storage**: Immediate access to frequently used preferences
- **Cloud Sync**: Synchronize preferences across devices
- **Encrypted Storage**: Protect sensitive preference data
- **Backup and Restore**: Recover preferences after device changes

#### Preference Categories
- **Interface Preferences**: Theme, layout, language settings
- **Communication Preferences**: Notification frequency and channels
- **Workflow Preferences**: Default actions and shortcuts
- **Privacy Preferences**: Data sharing and consent settings

### Progress Tracking
Monitor user progress through onboarding to provide personalized experiences.

#### Tracking Mechanisms
- **Completion Metrics**: Measure progress through onboarding steps
- **Engagement Analytics**: Track user interactions and interest areas
- **Drop-off Points**: Identify where users abandon onboarding
- **Success Indicators**: Measure post-onboarding user satisfaction

#### Data Utilization
- **Personalized Recommendations**: Suggest relevant features based on behavior
- **Optimization Opportunities**: Improve onboarding based on aggregate data
- **Individual Support**: Identify users who may need additional assistance
- **A/B Testing**: Experiment with different approaches to improve effectiveness

## Security and Privacy

### Data Protection
Implement robust security measures to protect user information during onboarding.

#### Measures
- **End-to-End Encryption**: Protect data in transit and at rest
- **Minimal Data Collection**: Gather only essential information
- **Transparent Practices**: Clearly communicate data usage
- **User Control**: Allow users to manage their data and preferences

#### Compliance
- **GDPR**: European Union data protection regulations
- **CCPA**: California Consumer Privacy Act
- **Industry Standards**: HIPAA, SOC 2, ISO 27001 compliance where applicable
- **Regular Audits**: Periodic security assessments and improvements

### Consent Management
Obtain proper consent for data collection and processing activities.

#### Consent Types
- **Functional Consent**: Required for basic application functionality
- **Analytical Consent**: Optional consent for usage analytics
- **Marketing Consent**: Permission for promotional communications
- **Sharing Consent**: Approval for data sharing with partners

#### Management Features
- **Granular Controls**: Separate consent for different data uses
- **Easy Withdrawal**: Simple process to revoke consent
- **Clear Communication**: Understandable explanations of consent implications
- **Audit Trails**: Record of all consent-related activities

## Performance Optimization

### Loading Speed
Optimize onboarding screens for fast loading and smooth transitions.

#### Techniques
- **Lazy Loading**: Load content only when needed
- **Preloading**: Anticipate user needs and preload relevant assets
- **Caching Strategies**: Store frequently accessed data locally
- **Compression**: Reduce asset sizes without compromising quality

#### Metrics
- **First Paint**: Time to initial visual content display
- **Interactive Ready**: Time until users can interact with elements
- **Full Load**: Time to complete content and functionality availability
- **Frame Rates**: Smoothness of animations and transitions

### Resource Management
Efficiently manage system resources to ensure optimal performance.

#### Strategies
- **Memory Optimization**: Minimize memory footprint during onboarding
- **Battery Conservation**: Reduce power consumption on mobile devices
- **Network Efficiency**: Optimize data transfer and minimize requests
- **CPU Usage**: Limit processor-intensive operations during onboarding

## Testing and Quality Assurance

### Usability Testing
Conduct regular usability testing to identify friction points and improvement opportunities.

#### Testing Methods
- **Moderated Sessions**: Guided testing with facilitator observation
- **Unmoderated Sessions**: Remote testing with automated data collection
- **A/B Testing**: Compare different approaches to determine effectiveness
- **Multivariate Testing**: Test multiple variables simultaneously

#### Metrics Tracked
- **Completion Rates**: Percentage of users who complete onboarding
- **Drop-off Points**: Where users abandon the onboarding process
- **Time to Completion**: Average time to finish onboarding
- **User Satisfaction**: Post-onboarding satisfaction ratings

### Accessibility Testing
Ensure the onboarding experience meets accessibility standards for all users.

#### Testing Approaches
- **Automated Scanning**: Tools to identify common accessibility issues
- **Manual Evaluation**: Expert review of accessibility compliance
- **User Testing**: Feedback from users with disabilities
- **Continuous Monitoring**: Ongoing assessment during development

#### Standards Verified
- **WCAG 2.1 AA**: Web Content Accessibility Guidelines compliance
- **Section 508**: US federal accessibility standards
- **EN 301 549**: European accessibility requirements
- **Mobile Accessibility**: Platform-specific mobile accessibility guidelines

## Localization

### Multi-language Support
Provide onboarding experiences in multiple languages to serve global audiences.

#### Languages Supported
- **English**: Primary language with regional variants
- **Spanish**: Major world language with broad reach
- **French**: Widely spoken in Europe, Africa, and Canada
- **German**: Important European market
- **Japanese**: Key Asian market
- **Chinese**: Simplified and Traditional variants

#### Implementation
- **Resource Bundles**: Language-specific text and media
- **Dynamic Switching**: Runtime language changes
- **Right-to-Left Support**: Full RTL language compatibility
- **Cultural Adaptation**: Regionally appropriate content and imagery

### Cultural Sensitivity
Adapt onboarding content to respect cultural differences and preferences.

#### Considerations
- **Color Meanings**: Cultural significance of colors in different regions
- **Imagery**: Culturally appropriate visuals and representations
- **Naming Conventions**: Regional variations in name formats
- **Date/Time Formats**: Localized presentation of temporal information

## Analytics and Insights

### User Behavior Tracking
Collect anonymous usage data to improve the onboarding experience.

#### Data Collected
- **Navigation Patterns**: How users move through onboarding screens
- **Interaction Points**: Which elements users engage with most
- **Drop-off Locations**: Where users abandon onboarding
- **Completion Times**: How long onboarding takes for different users

#### Privacy Protection
- **Anonymization**: Remove personally identifiable information
- **Opt-in Consent**: Require explicit permission for analytics collection
- **Data Minimization**: Collect only essential analytics data
- **Secure Transmission**: Protect data during collection and storage

### Performance Monitoring
Continuously monitor onboarding performance to identify and resolve issues.

#### Metrics Tracked
- **Load Times**: Page and asset loading performance
- **Error Rates**: Frequency of technical issues during onboarding
- **Conversion Rates**: Percentage of onboarding completions
- **User Feedback**: Qualitative insights from user surveys

#### Alerting System
- **Threshold Monitoring**: Automated alerts when metrics exceed normal ranges
- **Root Cause Analysis**: Tools to identify underlying causes of issues
- **Remediation Workflows**: Processes for quickly addressing problems
- **Stakeholder Notifications**: Communication with relevant teams about issues

## Future Enhancements

### AI-Powered Personalization
Leverage artificial intelligence to create truly personalized onboarding experiences.

#### Potential Features
- **Predictive Onboarding**: Anticipate user needs based on behavior patterns
- **Adaptive Content**: Dynamically adjust content based on user responses
- **Intelligent Assistance**: AI-powered help that understands user context
- **Sentiment Analysis**: Gauge user frustration and adjust accordingly

### Augmented Reality Integration
Use AR technology to create immersive onboarding experiences.

#### Applications
- **Virtual Tours**: 3D walkthroughs of key application features
- **Interactive Demonstrations**: Hands-on practice with virtual elements
- **Spatial Learning**: Better understanding through spatial relationships
- **Engagement Gamification**: Game-like elements that increase motivation

### Social Onboarding
Leverage social connections to enhance the onboarding experience.

#### Features
- **Peer Mentoring**: Connect new users with experienced colleagues
- **Social Proof**: Show how others are successfully using the application
- **Collaborative Learning**: Group activities that build team cohesion
- **Community Building**: Foster connections that extend beyond onboarding

## Conclusion

The AttendanceApp's onboarding system represents a thoughtful approach to introducing new users to a comprehensive attendance management solution. By combining educational content, interactive tutorials, and progressive feature disclosure, the system ensures users understand the application's value while feeling confident in their ability to use it effectively.

Through continuous monitoring, testing, and iteration, the onboarding experience will evolve to meet changing user needs and technological capabilities, ensuring that every new user has a positive first experience with the application.