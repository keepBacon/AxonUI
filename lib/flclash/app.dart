import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens.dart';
import 'store.dart';
import 'theme.dart';
import 'glass.dart';

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
  bool _themeOpen=true;
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
    title:'Axon UI · FlClash',debugShowCheckedModeBanner:false,
    theme:flTheme(brightness:Brightness.light,seed:_seed,glass:_glass),
    darkTheme:flTheme(brightness:Brightness.dark,seed:_seed,glass:_glass),
    themeMode:_mode,
    home:FlGlassScope(level:_glass,child:FlAmbientBackdrop(level:_glass,child:AnimatedSwitcher(
      duration:const Duration(milliseconds:260),
      switchInCurve:Curves.easeOutCubic,
      child:_themeOpen
        ? FlThemeScreen(key:const ValueKey('theme'),
          onBack:()=>setState(()=>_themeOpen=false),mode:_mode,seed:_seed,
          onMode:_setMode,onSeed:_setSeed,glass:_glass,onGlass:_setGlass,store:_store)
        : FlNavigationShell(key:const ValueKey('shell'),
          openTheme:()=>setState(()=>_themeOpen=true)),
    ))),
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
  final bool _floating=true;
  @override
  Widget build(BuildContext context){
    final scheme=Theme.of(context).colorScheme;
    final pages=<Widget>[
      FlOverviewScreen(openTheme:widget.openTheme),
      const FlControlsScreen(),
      const FlProfilesScreen(),
    ];
    return Scaffold(body:SafeArea(child:Stack(children:[
      Positioned.fill(child:AnimatedSwitcher(
        duration:FlMotion.effective(context,FlMotion.page),
        transitionBuilder:(child,animation)=>FadeTransition(
          opacity:animation,child:SlideTransition(
            position:Tween(begin:const Offset(.045,0),end:Offset.zero)
              .animate(CurvedAnimation(parent:animation,curve:FlMotion.curve)),
            child:child)),
        child:KeyedSubtree(key:ValueKey('page-$_selected'),child:pages[_selected]),
      )),
      Positioned(left:18,right:18,bottom:14,
        child:FlGlassSurface(radius:_floating?30:18,shadow:true,
          child:Padding(padding:const EdgeInsets.all(7),
              child:Row(children:[
                for(var i=0;i<4;i++) Expanded(child:InkWell(
                  key:ValueKey('tab-$i'),
                  borderRadius:BorderRadius.circular(23),
                  onTap:(){
                    if(i==3){widget.openTheme();return;}
                    setState(()=>_selected=i);
                  },
                  child:AnimatedContainer(
                    height:56,duration:FlMotion.effective(context),
                    curve:FlMotion.curve,
                    decoration:BoxDecoration(
                      color:i==_selected?scheme.primaryContainer:Colors.transparent,
                      borderRadius:BorderRadius.circular(22)),
                    child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
                      AnimatedScale(scale:i==_selected?1.06:1.0,
                        duration:FlMotion.effective(context,FlMotion.short),
                        child:Icon([Icons.dashboard_rounded,Icons.tune_rounded,
                          Icons.folder_outlined,Icons.palette_outlined][i],
                          size:22,color:i==_selected?scheme.primary:flMuted(context))),
                      const SizedBox(height:2),
                      Text(['概览','控件','配置','主题'][i],
                        style:TextStyle(fontSize:11,
                          fontWeight:i==_selected?FontWeight.w700:FontWeight.w400,
                          color:i==_selected?scheme.primary:flMuted(context))),
                    ])),
                )),
              ]))),
        ),
    ])));
  }
}
