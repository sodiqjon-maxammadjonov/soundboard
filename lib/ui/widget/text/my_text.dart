import '../../../data/library/libray.dart';

class MyText extends StatelessWidget {
  final String content;
  final int maxLines;
  final TextAlign? textAlign;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  const MyText({
    super.key,
    required this.content,
    this.maxLines = 3,
    this.textAlign,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w400,
    this.color = CupertinoColors.label,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign ?? TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: 0.5,
        height: 1.3,
      ),
    );
  }
}
