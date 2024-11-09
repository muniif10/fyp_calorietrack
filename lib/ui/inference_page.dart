import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class inference_page extends StatelessWidget {
  inference_page({super.key});
  final ImagePicker imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          flex: 4,
          child: ListView.builder(
            itemBuilder: (context, index) {
              return card();
            },
            scrollDirection: Axis.horizontal,
            itemCount: 2,
          ),
        ),
        Flexible(flex: 2,
            child: Column(
          children: [
            Text("Food"),
            Text("Quantity"),
            ElevatedButton(
                onPressed: () async {
                  final result = await imagePicker.pickImage(
                    source: ImageSource.camera,
                  );

                  String imagePath = result?.path ?? "No image selected";
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(imagePath)));
                },
                child: Text("Add food"))
          ],
        ))
      ],
    ));
  }

  Widget card() {
    return Container(margin: const EdgeInsets.all(5),
      child: AspectRatio(
        aspectRatio: 3/1,
        child: Image.network(
          "https://github.com/michael-gh1/Addons-And-Tools-For-Blender-miHoYo-Shaders/raw/main/assets/gi_hsr_pgr_banner.jpg",
        ),
      ),
    );
  }
}
