import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CookieSettingsModal extends StatefulWidget {

  void Function(bool, bool) setConsent;
  void Function() close;

  CookieSettingsModal({
    Key? key,
    required this.setConsent,
    required this.close
  }) : super(key: key);

  @override
  _CookieSettingsModalState createState() => _CookieSettingsModalState();
}

class _CookieSettingsModalState extends State<CookieSettingsModal> {
  bool _analyticsAllowed = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Container(
          padding: EdgeInsets.all(32.0),
          margin: EdgeInsets.all(20.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                  textAlign: TextAlign.center,
                'Nastavenia Cookies',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge!
                    .copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              SwitchListTile(
                title: Text('Nevyhnutne nutné súbory cookie'),
                value: true,
                onChanged: (bool value) {
                  
                },
              ),
              Text(
                'Sú to základné súbory cookie, ktoré umožňujú pohybovať sa po webovej stránke a používať jej funkcie. Tieto súbory cookie neukladajú žiadne informácie o vás, ktoré by sa dali použiť na marketing alebo na zapamätanie si, čo ste si na internete pozerali.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              SwitchListTile(
                title: Text('Analytické súbory cookies'),
                value: _analyticsAllowed,
                onChanged: (bool value) {
                  setState(() {
                  _analyticsAllowed = value;
                    
                  });
                },
              ),
              Text(
                'Sú to základné súbory cookie, ktoré umožňujú pohybovať sa po webovej stránke a používať jej funkcie. Tieto súbory cookie neukladajú žiadne informácie o vás, ktoré by sa dali použiť na marketing alebo na zapamätaniesi, čo ste si na internete pozerali.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              Row(
                children: [
                  Spacer(),
                  TextButton(onPressed: () {
                    widget.setConsent(true, _analyticsAllowed);
                    widget.close();
                  } , child: Text(
                    'ULOŽIŤ NASTAVENIA',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),),
                  TextButton(onPressed: () {
                    widget.close();
                  }, child: Text(
                    'ZATVORIŤ',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),),
                ],
              )

            ],
          ),
        ),
    );
  }
}
