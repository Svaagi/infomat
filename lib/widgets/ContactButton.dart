import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContactButton extends StatelessWidget {
  String type;
  TextEditingController messageController;
  Future Function(String, String) sendMessage;

  ContactButton({
    Key? key,
    required this.type,
    required this.messageController,
    required this.sendMessage
    
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: 190,
      height: 40,
      child: ReButton(
        activeColor: AppColors.getColor('primary').light, 
        defaultColor: AppColors.getColor('mono').lighterGrey, 
        disabledColor: AppColors.getColor('mono').lightGrey, 
        focusedColor: AppColors.getColor('primary').light, 
        hoverColor: AppColors.getColor('primary').lighter, 
        textColor: AppColors.getColor('primary').main, 
        iconColor: AppColors.getColor('mono').black, 
        text: 'Kontaktuje nás',
        rightIcon: 'assets/icons/messageIcon.svg',
        onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  content: Container(
                    width: 500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Ensure the dialog takes up minimum height
                      children: [
                        Row(
                          children: [
                            const Spacer(),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                child: SvgPicture.asset('assets/icons/xIcon.svg', height: 10,),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 30,),
                          Text(
                            'Moja správa je',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10,),
                          Container(
                            padding: EdgeInsets.only(right: 8),
                            height: 30,
                            width: 200,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: type == 'Nahlásenie problému' ? AppColors.getColor('primary').lighter : AppColors.getColor('mono').lighterGrey,
                            ),
                            child: Row(
                              children: [
                                Radio(
                                  value: 'Nahlásenie problému',
                                    groupValue: type,
                                    onChanged: (newValue) {
                                      setState(() {
                                        if (newValue != null) type = newValue;
                                      });
                                    },
                                    activeColor: AppColors.getColor('primary').main,
                                  ),
                                Text(
                                  'Nahlásenie problému',
                                  style: TextStyle(
                                    color:  type == 'Nahlásenie problému' ? AppColors.getColor('primary').main : AppColors.getColor('mono').darkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            padding: EdgeInsets.only(right: 8),
                            height: 30,
                            width: 100,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: type == 'Otázka' ? AppColors.getColor('primary').lighter : AppColors.getColor('mono').lighterGrey,
                            ),
                            child: Row(
                              children: [
                                  Radio(
                                  value: 'Otázka',
                                    groupValue: type,
                                    onChanged: (newValue) {
                                      setState(() {
                                        if (newValue != null) type = newValue;
                                      });
                                    },
                                    activeColor: AppColors.getColor('primary').main,
                                  ),
                                Text(
                                  'Otázka',
                                  style: TextStyle(
                                    color: type == 'Otázka' ? AppColors.getColor('primary').main : AppColors.getColor('mono').darkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text(
                            'Správa',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10,),
                          reTextField(
                            'Popíš svoj problém s aplikáciou alebo nám napíš otázku.',
                            false,
                            messageController,
                            AppColors.getColor('mono').white, // assuming white is the default border color you want
                          ),
                        SizedBox(height: 30,),
                          Center(
                            child: ReButton(
                            activeColor: AppColors.getColor('mono').white, 
                            defaultColor: AppColors.getColor('green').main, 
                            disabledColor: AppColors.getColor('mono').lightGrey, 
                            focusedColor: AppColors.getColor('green').light, 
                            hoverColor: AppColors.getColor('green').light, 
                            textColor: Theme.of(context).colorScheme.onPrimary, 
                            iconColor: AppColors.getColor('mono').black, 
                            text: 'ODOSLAŤ',
                            onTap: () {
                              if(messageController.text != '') {
                                sendMessage(messageController.text, type);
                                Navigator.of(context).pop();
                                messageController.text = '';
                              }
                            },
                          ),
                        ),
                        
                        SizedBox(height: 30,),
                      ],
                    ),
                  )
                );
                  }
                );
              },
            );
        }
      )
    );
  }
}