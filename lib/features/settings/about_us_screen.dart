import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ringo_ringtones/l10n/app_localizations.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutUs),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(
            context,
            role: l10n.roleDeveloper,
            name: "Sachin Verma",
            telegram: "@leafdesign",
            twitter: "@sachinxpert",
            avatarColor: Colors.teal,
            imageUrl: "https://i.ibb.co/DHt6nGf3/IMG-20250623-111737-142.jpg",
          ),
          const SizedBox(height: 24),
          _buildProfileCard(
            context,
            role: l10n.roleAppOwner,
            name: "Purvesh Shinde",
            telegram: "@purveshshinde",
            twitter: "@droiddecor",
            avatarColor: Colors.indigoAccent,
            imageUrl: "https://pbs.twimg.com/profile_images/1621021404467716097/_PbHoEMp_400x400.jpg",
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, {
    required String role,
    required String name,
    required String telegram,
    required String twitter,
    required Color avatarColor,
    String? imageUrl,
  }) {
    // Determine card background color for better separation
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surface;
    final borderColor = isDark ? Colors.white10 : Colors.black.withOpacity(0.05);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: avatarColor.withOpacity(0.5), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 32, // Smaller radius
                    backgroundColor: avatarColor.withOpacity(0.1),
                    backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                    child: imageUrl == null ? Text(
                      name[0],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: avatarColor,
                      ),
                    ) : null,
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: avatarColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
             ],
           ),
           const SizedBox(height: 16),
           const Divider(height: 1),
           const SizedBox(height: 16),
           // Compact Social Row
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
               _buildCompactSocial(context, Icons.send, telegram, Colors.blue),
               _buildCompactSocial(context, Icons.alternate_email, twitter, Colors.lightBlue),
             ],
           ),
        ],
      ),
    );
  }

  Widget _buildCompactSocial(BuildContext context, IconData icon, String handle, Color color) {
    return InkWell(
      onTap: () {
          // Identify platform based on icon or passed context if needed, 
          // but for now relying on handle context or passing platform could be better.
          // Simplification: Infer or pass platform.
          // Re-using launch logic needs platform. 
          // Quick fix: Check icon or pass platform string.
          String platform = icon == Icons.send ? "Telegram" : "Twitter";
          _launchSocial(context, platform, handle);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              handle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchSocial(BuildContext context, String platform, String handle) async {
    final cleanHandle = handle.replaceAll('@', '');
    Uri? url;
    
    if (platform == "Telegram") {
      url = Uri.parse("https://t.me/$cleanHandle");
    } else if (platform == "Twitter") {
      url = Uri.parse("https://twitter.com/$cleanHandle");
    }

    if (url != null) {
       try {
         if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenLink)),
              );
            }
         }
       } catch (e) {
         debugPrint("Could not launch $url: $e");
         if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric(e.toString()))),
            );
         }
       }
    }
  }
}
