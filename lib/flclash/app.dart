import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens.dart';
import 'feature_pages.dart';
import 'store.dart';
import 'theme.dart';
import 'glass.dart';
import 'motion.dart';
import 'original_navigation_dock.dart';
import 'upstream_liquid_glass.dart';

class FlClashAxonApp extends StatefulWidget {
  const FlClashAxonApp({super.key,this.store});
  final FlUiStore? store;
  @override
  State<FlClashAxonApp> createState()=>_FlClashAxonAppState();
}
class _FlClashAxonAppState extends State<FlClashAxonApp>{
  late final FlUiStore _store=widget.store ?? (
    !kIsWeb && defaultTargetPlatform==TargetPlatform.android
      ? const FlAndroidStore() : FlMemoryStore());
  ThemeMode _mode=ThemeMode.system;
  Color _seed=FlTokens.blue;
  int _glass=2;
  bool _themeOpen=false;
  @override
  void initState(){super.initState();_load();}
  Future<void> _load()async{
    try{final data=await _store.load();if(!mounted)return;
      setState((){
        final mode=data['theme_mode']?.toString();
        for(final candidate in ThemeMode.values){if(candidate.name==mode)_mode=candidate;}
        final raw=data['theme_seed'];if(raw is int)_seed=Color(raw);
        final glass=data['glass'];if(glass is int)_glass=glass.clamp(0,2);
      });
    }catch(_){/* Display app remains useful without native prefs. */}
  }
  void _setMode(ThemeMode value){
    setState(()=>_mode=value);_store.save('theme_mode',value.name);
  }
  void _setSeed(Color value){
    setState(()=>_seed=value);_store.save('theme_seed',value.toARGB32());
  }
  void _setGlass(int level){
    final next=level.clamp(0,2);
    setState(()=>_glass=next);
    _store.save('glass',next);
  }
  @override
  Widget build(BuildContext context)=>MaterialApp(
    title:'控件展示',debugShowCheckedModeBanner:false,
    theme:flTheme(brightness:Brightness.light,seed:_seed,glass:_glass),
    darkTheme:flTheme(brightness:Brightness.dark,seed:_seed,glass:_glass),
    themeMode:_mode,
    home:LiquidGlassScope(enabled:_glass>0,
      quality:_glass==1?LiquidGlassQuality.standard:LiquidGlassQuality.ultra,
      child:LiquidGlassHost(enabled:_glass>0,
      child:FlGlassScope(level:_glass,
      child:FlAmbientBackdrop(level:_glass,child:FlFadeThrough(
      child:_themeOpen
        ? FlThemeScreen(key:const ValueKey('theme'),
          onBack:()=>setState(()=>_themeOpen=false),mode:_mode,seed:_seed,
          onMode:_setMode,onSeed:_setSeed,glass:_glass,onGlass:_setGlass,store:_store)
        : FlNavigationShell(key:const ValueKey('shell'),
          openTheme:()=>setState(()=>_themeOpen=true)),
    ))))),
  );
}

/// FlClash-like navigation, pill indicator, blur, and animated tab pages.
class FlNavigationShell extends StatefulWidget {
  const FlNavigationShell({super.key,required this.openTheme});
  final VoidCallback openTheme;
  @override
  State<FlNavigationShell> createState()=>_FlNavigationShellState();
}
class _FlNavigationShellState extends State<FlNavigationShell>{
  int _selected=0;
  @override
  Widget build(BuildContext context){
    final pages=<Widget>[
      FlPreviewHomeScreen(onSelect:(i)=>setState(()=>_selected=i)),
      const FlKeyDisplayScreen(),
      const FlPluginShowcaseScreen(),
      FlOtherShowcaseScreen(openTheme:widget.openTheme),
    ];
    return Scaffold(body:SafeArea(child:Stack(children:[
      Positioned.fill(child:FlFadeThrough(
        child:KeyedSubtree(key:ValueKey('page-$_selected'),child:pages[_selected]),
      )),
      // Directly uses the FlClash navigation_dock.dart spring/lens engine.
      Positioned(left:0,right:0,bottom:0,
        child:NavigationDock(
          selectedIndex:_selected,
          destinations:const [
            NavigationDockDestination(glyph:Icons.home_outlined,label:'主页'),
            NavigationDockDestination(glyph:Icons.keyboard_outlined,label:'键显'),
            NavigationDockDestination(glyph:Icons.extension_outlined,label:'插件'),
            NavigationDockDestination(glyph:Icons.tune_outlined,label:'其他'),
          ],
          onSelected:(i){
            if(i!=_selected)setState(()=>_selected=i);
          },
        )),
    ])));
  }
}
