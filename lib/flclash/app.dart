import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens.dart';
import 'axon_gallery.dart';
import 'store.dart';
import 'theme.dart';
import 'glass.dart';
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
      child:FlAmbientBackdrop(level:_glass,child:AnimatedSwitcher(
      duration:const Duration(milliseconds:260),
      switchInCurve:const Interval(.5,1,curve:Curves.easeOutCubic),
      switchOutCurve:const Interval(.5,1,curve:Curves.easeInCubic),
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
      FlAxonCatalogueScreen(
        onControls:()=>setState(()=>_selected=1),
        onSchema:()=>setState(()=>_selected=2),
        onTheme:widget.openTheme,
      ),
      const FlAxonControlsScreen(),
      const FlProfilesScreen(),
    ];
    return Scaffold(body:SafeArea(child:Stack(children:[
      Positioned.fill(child:AnimatedSwitcher(
        duration:FlMotion.effective(context,FlMotion.page),
        switchInCurve:const Interval(.5,1,curve:Curves.easeOutCubic),
        switchOutCurve:const Interval(.5,1,curve:Curves.easeInCubic),
        transitionBuilder:(child,animation)=>FadeTransition(
          opacity:animation,child:SlideTransition(
            position:Tween(begin:const Offset(.035,0),end:Offset.zero)
              .animate(animation),
            child:child)),
        child:KeyedSubtree(key:ValueKey('page-$_selected'),child:pages[_selected]),
      )),
      // Directly uses the FlClash navigation_dock.dart spring/lens engine.
      Positioned(left:0,right:0,bottom:0,
        child:NavigationDock(
          selectedIndex:_selected,
          destinations:const [
            NavigationDockDestination(glyph:Icons.grid_view_rounded,label:'组件库'),
            NavigationDockDestination(glyph:Icons.tune_rounded,label:'控件'),
            NavigationDockDestination(glyph:Icons.folder_outlined,label:'配置'),
            NavigationDockDestination(glyph:Icons.palette_outlined,label:'主题'),
          ],
          onSelected:(i){
            if(i==3){widget.openTheme();return;}
            if(i!=_selected)setState(()=>_selected=i);
          },
        )),
    ])));
  }
}
