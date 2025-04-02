import 'package:ct484_project/pages/widgets/custom_button.dart';
import 'package:flutter/material.dart';
class StartScreen extends StatelessWidget {

   const StartScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return SafeArea(
child:Scaffold(
  body: Column(
    children: [
        Expanded(
          flex: 2,
          child: Image.asset(
            "assets/images/Board.png",
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        ),
         Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Nấu ăn theo phong cách của bạn",
                  // style: Theme.of(context).textTheme.headine1,
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: 220,
                  child: Text(
                    "Tham gia với chúng tôi để nấu ngon hơn mỗi ngày",
                    // style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                // CustomButton(
                //   onTap: () {
                //     Navigator.pushAndRemoveUntil(
                //         context,
                //         MaterialPageRoute(builder: (context) => SignInScreen()),
                //         (route) => false);
                //   },
                //   text: "Get Started",
                // ),
              ],
            ),
          ),
        ),
    ],
    
    )
)

   );
  }
}