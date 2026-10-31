import 'dart:convert';
import 'package:flutter/material.dart';
import 'controls.dart';
import 'theme.dart';

/// Axon-Input KeyboardCatFunctionBindingStore / BongoCatStyleManager /
/// Live2DDebugSettingsStore / Live2DPhysicsSettingsStore mock UI.
/// The metadata below is sampled from bundled
/// bongocat/keyboard/demomodel2.cdi3.json and cat.model3.json.
/// The imported model catalogue is dynamic in Axon-Input; this showcase
/// deliberately does not discover files or call its native runtime.
class FlKeyboardCatDebugStudio extends StatefulWidget {
  const FlKeyboardCatDebugStudio({super.key,this.initialSection=0});
  final int initialSection;
  @override State<FlKeyboardCatDebugStudio> createState()=>
      _FlKeyboardCatDebugStudioState();
}

class _CatItem {
  const _CatItem(this.id,this.name,this.family);
  final String id,name,family;
}

class _CatAction {
  const _CatAction(this.token,this.name,this.kind,this.defaultMode);
  final String token,name,kind,defaultMode;
}

class _FlKeyboardCatDebugStudioState extends State<FlKeyboardCatDebugStudio> {
  late int section;
  bool active=true;
  String activeToken='param:Param3',query='';
  int previewCount=0;
  String parameterCategory='全部',actionCategory='全部';
  bool modifiedOnly=false,lockedOnly=false;
  String? bindingNotice;
  late final TextEditingController _parameterSearch;
  // These are real ids and names from the sample cdi3.json.
  // All 34 IDs/names from bundled sample CDI3, grouped by UI semantics.
  static const params=<_CatItem>[
    _CatItem('ParamAngleX','角度 X','姿态'),
    _CatItem('ParamAngleY','角度 Y','姿态'),
    _CatItem('CatParamRightHandDown','右手按下','手部'),
    _CatItem('CatParamLeftHandDown','左手按下','手部'),
    _CatItem('ParamAngleZ','角度 Z','姿态'),
    _CatItem('ParamEyeLOpen','左眼 开闭','表情'),
    _CatItem('ParamEyeLSmile','左眼 微笑','表情'),
    _CatItem('ParamEyeROpen','右眼','表情'),
    _CatItem('ParamEyeRSmile','右眼 微笑','表情'),
    _CatItem('Param3','挥手','功能'),
    _CatItem('Param','开启闪电','功能'),
    _CatItem('Param2','闪电划过','功能'),
    _CatItem('Param4','表情:thuglife','表情'),
    _CatItem('Param5','表情:升天','表情'),
    _CatItem('ParamEyeBallX','眼球 X','表情'),
    _CatItem('ParamEyeBallY','眼球 Y','表情'),
    _CatItem('ParamBrowLY','左眉上下','表情'),
    _CatItem('ParamBrowRY','右眉 上下','表情'),
    _CatItem('ParamBrowLX','左眉 左右','表情'),
    _CatItem('ParamBrowRX','右眉 左右','表情'),
    _CatItem('ParamBrowLAngle','左眉 角度','表情'),
    _CatItem('ParamBrowRAngle','右眉 角度','表情'),
    _CatItem('ParamBrowLForm','左眉 変形','表情'),
    _CatItem('ParamBrowRForm','右眉 変形','表情'),
    _CatItem('ParamMouthForm','嘴部 变形','表情'),
    _CatItem('ParamMouthOpenY','嘴巴 张开和闭合','表情'),
    _CatItem('ParamCheek','脸颊','表情'),
    _CatItem('ParamBodyAngleX','身体旋转 X','姿态'),
    _CatItem('ParamBodyAngleY','身体旋转 Y','姿态'),
    _CatItem('ParamBodyAngleZ','身体旋转 Z','姿态'),
    _CatItem('ParamBreath','呼吸','姿态'),
    _CatItem('ParamHairFront','摇动 前发','头发'),
    _CatItem('ParamHairSide','摇动 侧发','头发'),
    _CatItem('ParamHairBack','摇动 后发','头发'),
  ];
  // Token prefixes and model actions are defined by BongoCatStyleManager.
  static const actions=< _CatAction>[
    _CatAction('param:Param3','挥手','参数动作','toggle'),
    _CatAction('param:Param','开启闪电','参数动作','toggle'),
    _CatAction('sequence:ParamGroup','闪电 · 组合序列','参数序列','sequence'),
    _CatAction('expression:0','表情 0','表情','pulse'),
    _CatAction('expression:1','表情 1','表情','pulse'),
    _CatAction('motion:0','CAT_motion / 0','动作','pulse'),
    _CatAction('motion:1','CAT_motion / 1','动作','pulse'),
  ];
  static const bindingChoices=<String>[
    '未绑定','W','A','S','D','Space','Mouse4','Pad A'];
  static const modeValues=<String>['hold','toggle','pulse','sequence'];
  static const modeNames=<String>['按住','切换','脉冲','序列'];
  final bindings=<String,String>{};
  final actionModes=<String,String>{};
  final overrides=<String,double>{};
  final locks=<String,bool>{};
  final expressionWeights=<String,double>{
    'expression:0':100,'expression:1':100,'expression:2':100};
  final physicsStrengths=<String,double>{
    '演示组 A':100,'演示组 B':100};
  final physicsEnabled=<String,bool>{
    '演示组 A':true,'演示组 B':true};
  final physicsHotkeys=<String,String>{
    '演示组 A':'未绑定','演示组 B':'未绑定'};
  final physicsHotkeyEnabled=<String,bool>{
    '演示组 A':false,'演示组 B':false};
  double globalPhysics=100;
  @override void initState(){
    super.initState();
    _parameterSearch=TextEditingController();
    section=widget.initialSection.clamp(0,4);
    for(final a in actions)actionModes[a.token]=a.defaultMode;
  }
  @override void dispose(){
    _parameterSearch.dispose();
    super.dispose();
  }
  void _reset(){
    setState((){
      bindings.clear();
      actionModes.clear();
      for(final a in actions)actionModes[a.token]=a.defaultMode;
      overrides.clear();
      locks.clear();
      expressionWeights.updateAll((key,value)=>100);
      physicsEnabled.updateAll((key,value)=>true);
      physicsStrengths.updateAll((key,value)=>100);
      physicsHotkeys.updateAll((key,value)=>'未绑定');
      physicsHotkeyEnabled.updateAll((key,value)=>false);
      globalPhysics=100;
      activeToken='param:Param3';
      previewCount=0;
      parameterCategory='全部';actionCategory='全部';
      modifiedOnly=false;lockedOnly=false;
      query='';bindingNotice=null;
      _parameterSearch.clear();
    });
  }
  void _bind(String token,String value) {
    setState((){
      // The native store guarantees one input maps to one model action.
      bindingNotice=null;
      if(value!='未绑定'){
        for(final key in bindings.keys.toList()){
          if(key!=token&&bindings[key]==value){
            bindings.remove(key);
            bindingNotice='已将 '+value+' 从 '+key+' 转移到 '+token;
          }
        }
      }
      if(value=='未绑定'){bindings.remove(token);}
      else{bindings[token]=value;}
    });
  }
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      FlPanel(padding:const EdgeInsets.all(15),child:Column(
        crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          Row(children:[
            Icon(Icons.pets_outlined,color:cs.primary,size:24),
            const SizedBox(width:9),
            const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('键盘猫 · 模型调试',style:TextStyle(
                fontWeight:FontWeight.w700,fontSize:17)),
              Text('Cubism / BongoCat · 交互式样本',
                style:TextStyle(fontSize:11)),
            ])),
            Switch.adaptive(key:const ValueKey('cat-demo-enabled'),
              value:active,onChanged:(v)=>setState(()=>active=v)),
          ]),
          const SizedBox(height:9),
          Text('静态样本：bongocat/keyboard/demomodel2.cdi3.json',
            style:TextStyle(fontSize:11,color:cs.onSurfaceVariant)),
          const SizedBox(height:12),
          Container(
            key:const ValueKey('cat-demo-preview'),
            height:107,decoration:BoxDecoration(
              gradient:LinearGradient(colors:[
                cs.primary.withValues(alpha:.14),
                cs.tertiary.withValues(alpha:.13)]),
              borderRadius:BorderRadius.circular(17)),
            child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[
              AnimatedOpacity(
                opacity:active?1:.3,
                duration:FlMotion.effective(context,FlMotion.regular),
                child:Icon(previewCount.isEven?Icons.pets_rounded:
                  Icons.sentiment_very_satisfied_rounded,
                  color:cs.primary,size:57)),
              const SizedBox(width:16),
              Flexible(child:Column(
                mainAxisAlignment:MainAxisAlignment.center,
                crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Text('简化状态预览',style:TextStyle(
                    color:cs.onSurface,fontWeight:FontWeight.w700)),
                  const SizedBox(height:5),
                  Text('当前：'+activeToken,
                    maxLines:2,overflow:TextOverflow.ellipsis,
                    key:const ValueKey('cat-active-token'),
                    style:TextStyle(fontSize:11,color:cs.onSurfaceVariant)),
                  Text('触发 '+previewCount.toString()+' 次',
                    key:const ValueKey('cat-preview-count'),
                    style:TextStyle(fontSize:11,color:cs.primary)),
                ])),
            ]),
          ),
          const SizedBox(height:8),
          Text('示意图标不代表真实模型渲染；不连接模型文件或输入事件',
            style:TextStyle(color:cs.onSurfaceVariant,fontSize:10)),
        ])),
      const SizedBox(height:12),
      FlPanel(padding:const EdgeInsets.symmetric(horizontal:13,vertical:12),
        child:Row(children:[
          Expanded(child:_stat('参数',params.length.toString())),
          Expanded(child:_stat('已修改',overrides.length.toString())),
          Expanded(child:_stat('已锁定',
            locks.values.where((v)=>v).length.toString())),
          Expanded(child:_stat('已绑定',bindings.length.toString())),
        ])),
      const SizedBox(height:12),
      FlSegmented<int>(
        values:const [0,1,2,3,4],value:section,
        label:(n)=>const ['功能','参数','表情','物理','状态'][n],
        onChanged:(v)=>setState(()=>section=v)),
      const SizedBox(height:12),
      if(section==0)_functions()
      else if(section==1)_parameters()
      else if(section==2)_expressions()
      else if(section==3)_physics()
      else _diagnostics(),
      const SizedBox(height:12),
      OutlinedButton.icon(
        key:const ValueKey('cat-debug-reset'),
        onPressed:_reset,icon:const Icon(Icons.restart_alt_rounded),
        label:const Text('重置此演示的参数和绑定')),
    ]);
  }
  Widget _functions(){
    final cs=Theme.of(context).colorScheme;
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      _heading('模型功能与快捷键',actions.length.toString()+' 个样本动作'),
      Wrap(spacing:6,runSpacing:6,children:[
        for(final c in const ['全部','参数动作','参数序列','表情','动作'])
          ChoiceChip(key:ValueKey('cat-action-filter-'+c),
            label:Text(c),selected:actionCategory==c,
            onSelected:(_)=>setState(()=>actionCategory=c)),
      ]),
      const SizedBox(height:10),
      FlPanel(padding:const EdgeInsets.all(14),child:Column(children:[
        for(final (i,a) in actions.where((a)=>
          actionCategory=='全部'||a.kind==actionCategory).indexed)...[
          if(i!=0)const Divider(height:22),
          _actionRow(a),
        ],
      ])),
      if(bindingNotice!=null)Padding(
        padding:const EdgeInsets.only(top:9),
        child:Text(bindingNotice!,
          key:const ValueKey('cat-bind-notice'),
          style:TextStyle(color:cs.primary,fontSize:12))),
      const SizedBox(height:8),
      Text('绑定方式取自 KeyboardCatFunctionBindingStore：同一输入仅可绑定一个动作。',
        style:TextStyle(fontSize:11,color:cs.onSurfaceVariant)),
    ]);
  }
  Widget _actionRow(_CatAction action){
    final cs=Theme.of(context).colorScheme;
    final selected=activeToken==action.token;
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(action.name,style:TextStyle(
            color:cs.onSurface,fontSize:14,fontWeight:FontWeight.w600)),
          const SizedBox(height:2),
          Text(action.token,style:TextStyle(
            color:cs.onSurfaceVariant,fontSize:10)),
        ])),
        IconButton(
          key:ValueKey('cat-action-preview-'+action.token),
          tooltip:'演示触发 '+action.name,
          onPressed:()=>setState((){
            activeToken=action.token;previewCount++;
          }),
          icon:Icon(selected?Icons.play_circle_fill_rounded:
            Icons.play_circle_outline_rounded,color:cs.primary)),
      ]),
      const SizedBox(height:6),
      Row(children:[
        Expanded(child:DropdownButton<String>(
          key:ValueKey('cat-action-bind-'+action.token),
          isExpanded:true,value:bindings[action.token]??'未绑定',
          items:[for(final key in bindingChoices)
            DropdownMenuItem(value:key,child:Text(key,
              style:const TextStyle(fontSize:12)))],
          onChanged:(v){if(v!=null)_bind(action.token,v);},
        )),
        const SizedBox(width:10),
        Expanded(child:DropdownButton<String>(
          key:ValueKey('cat-action-mode-'+action.token),
          isExpanded:true,value:actionModes[action.token],
          items:[for(var i=0;i<modeValues.length;i++)
            DropdownMenuItem(value:modeValues[i],
              child:Text(modeNames[i],
                style:const TextStyle(fontSize:12)))],
          onChanged:(v){if(v!=null)setState(()=>actionModes[action.token]=v);},
        )),
      ]),
    ]);
  }
  Widget _parameters(){
    final cs=Theme.of(context).colorScheme;
    final term=query.trim().toLowerCase();
    final filtered=params.where((p)=>
      (p.id.toLowerCase().contains(term)||p.name.toLowerCase().contains(term))&&
      (parameterCategory=='全部'||p.family==parameterCategory)&&
      (!modifiedOnly||overrides.containsKey(p.id)||locks[p.id]==true)&&
      (!lockedOnly||locks[p.id]==true)).toList();
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      _heading('Cubism 参数覆盖与锁定','完整样本 '+params.length.toString()+' 项'),
      Wrap(spacing:6,runSpacing:6,children:[
        for(final c in const ['全部','姿态','手部','功能','表情','头发'])
          ChoiceChip(key:ValueKey('cat-param-category-'+c),
            label:Text(c),selected:parameterCategory==c,
            onSelected:(_)=>setState(()=>parameterCategory=c)),
      ]),
      const SizedBox(height:10),
      TextField(key:const ValueKey('cat-param-search'),
        controller:_parameterSearch,
        decoration:const InputDecoration(
          prefixIcon:Icon(Icons.search_rounded),
          hintText:'搜索参数 ID / 名称',isDense:true),
        onChanged:(v)=>setState(()=>query=v)),
      const SizedBox(height:10),
      Wrap(spacing:8,runSpacing:6,crossAxisAlignment:WrapCrossAlignment.center,
        children:[
          FilterChip(key:const ValueKey('cat-filter-modified'),
            label:const Text('仅修改项'),selected:modifiedOnly,
            onSelected:(v)=>setState(()=>modifiedOnly=v)),
          FilterChip(key:const ValueKey('cat-filter-locked'),
            label:const Text('仅锁定项'),selected:lockedOnly,
            onSelected:(v)=>setState(()=>lockedOnly=v)),
          Text('匹配 '+filtered.length.toString()+' 项',
            key:const ValueKey('cat-filter-count'),
            style:TextStyle(fontSize:12,color:cs.onSurfaceVariant)),
        ]),
      Row(children:[
        TextButton.icon(
          key:const ValueKey('cat-reset-filtered'),
          onPressed:filtered.isEmpty?null:()=>setState((){
            for(final p in filtered){
              overrides.remove(p.id);locks.remove(p.id);
            }
          }),
          icon:const Icon(Icons.restart_alt_rounded,size:18),
          label:const Text('重置筛选结果')),
        const Spacer(),
        TextButton(
          key:const ValueKey('cat-clear-filters'),
          onPressed:()=>setState((){
            _parameterSearch.clear();
            query='';parameterCategory='全部';
            modifiedOnly=false;lockedOnly=false;
          }),
          child:const Text('清除筛选')),
      ]),
      const SizedBox(height:7),
      FlPanel(padding:const EdgeInsets.all(14),child:Column(children:[
        if(filtered.isEmpty)const Text('没有匹配的样本参数'),
        for(final (i,p) in filtered.indexed)...[
          if(i!=0)const Divider(height:20),
          _parameterRow(p),
        ],
      ])),
      const SizedBox(height:8),
      Text('完整 34 项参数名称来自原始 cdi3；归一化演示值不代表真实 Cubism 参数范围。',
        style:TextStyle(fontSize:11,color:cs.onSurfaceVariant)),
    ]);
  }
  Widget _parameterRow(_CatItem p){
    final cs=Theme.of(context).colorScheme;
    final value=overrides[p.id]??.5;
    final locked=locks[p.id]??false;
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(p.name,style:const TextStyle(fontWeight:FontWeight.w600)),
          Text(p.id,style:TextStyle(
            fontSize:10,color:cs.onSurfaceVariant)),
        ])),
        Text(value.toStringAsFixed(2),
          key:ValueKey('cat-param-value-'+p.id),
          style:TextStyle(color:cs.primary,fontWeight:FontWeight.w700)),
        IconButton(
          key:ValueKey('cat-param-lock-'+p.id),
          tooltip:locked?'取消锁定':'锁定当前参数',
          onPressed:()=>setState(()=>locks[p.id]=!locked),
          icon:Icon(locked?Icons.lock_rounded:Icons.lock_open_outlined,
            size:19,color:locked?cs.primary:cs.onSurfaceVariant)),
        IconButton(
          tooltip:'恢复默认',
          key:ValueKey('cat-param-reset-'+p.id),
          onPressed:()=>setState((){
            overrides.remove(p.id);locks.remove(p.id);
          }),
          icon:const Icon(Icons.refresh_rounded,size:19)),
      ]),
      Slider(
        key:ValueKey('cat-param-slider-'+p.id),
        value:value,min:0,max:1,
        onChanged:(v)=>setState(()=>overrides[p.id]=v)),
    ]);
  }
  Widget _expressions(){
    final cs=Theme.of(context).colorScheme;
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      _heading('表情与动作权重','模型 model3 表情索引'),
      FlPanel(padding:const EdgeInsets.all(14),child:Column(children:[
        for(var i=0;i<3;i++)...[
          if(i!=0)const Divider(height:19),
          Row(children:[
            Icon(Icons.face_retouching_natural_rounded,color:cs.primary),
            const SizedBox(width:10),
            Expanded(child:Text('表情 '+i.toString(),
              style:const TextStyle(fontWeight:FontWeight.w600))),
            IconButton(
              key:ValueKey('cat-expression-preview-'+i.toString()),
              tooltip:'模拟预览表情',
              onPressed:()=>setState((){
                activeToken='expression:'+i.toString();
                previewCount++;
              }),
              icon:const Icon(Icons.play_arrow_rounded)),
          ]),
          Slider(
            key:ValueKey('cat-expression-weight-'+i.toString()),
            value:expressionWeights['expression:'+i.toString()]!,
            min:0,max:100,
            label:expressionWeights['expression:'+i.toString()]!.round().toString(),
            onChanged:(v)=>setState(()=>
              expressionWeights['expression:'+i.toString()]=v)),
        ],
      ])),
      const SizedBox(height:9),
      Text('表情数量来自附带样本 cat.model3.json；未读取用户导入的模型。',
        style:TextStyle(color:cs.onSurfaceVariant,fontSize:11)),
    ]);
  }
  Widget _physics(){
    final cs=Theme.of(context).colorScheme;
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      _heading('Physics 物理控制','强度上限 200%'),
      FlPanel(padding:const EdgeInsets.all(14),child:Column(children:[
        Row(children:[
          const Expanded(child:Text('全局物理强度',
            style:TextStyle(fontWeight:FontWeight.w700))),
          Text(globalPhysics.round().toString()+'%',
            style:TextStyle(color:cs.primary)),
        ]),
        Slider(key:const ValueKey('cat-physics-global'),
          value:globalPhysics,min:0,max:200,
          onChanged:(v)=>setState(()=>globalPhysics=v)),
      ])),
      const SizedBox(height:12),
      for(final name in physicsStrengths.keys)...[
        FlPanel(padding:const EdgeInsets.all(14),child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,children:[
            SwitchListTile.adaptive(
              key:ValueKey('cat-physics-enable-'+name),
              dense:true,contentPadding:EdgeInsets.zero,
              title:Text(name),subtitle:const Text('演示占位组，非样本模型真实 Physics 分组'),
              value:physicsEnabled[name]!,
              onChanged:(v)=>setState(()=>physicsEnabled[name]=v)),
            Row(children:[
              const Expanded(child:Text('分组强度')),
              Text(physicsStrengths[name]!.round().toString()+'%',
                style:TextStyle(color:cs.primary)),
            ]),
            Slider(key:ValueKey('cat-physics-strength-'+name),
              value:physicsStrengths[name]!,min:0,max:200,
              onChanged:(v)=>setState(()=>physicsStrengths[name]=v)),
            Row(children:[
              Expanded(child:DropdownButton<String>(
                key:ValueKey('cat-physics-hotkey-'+name),
                isExpanded:true,value:physicsHotkeys[name],
                items:[for(final choice in bindingChoices)
                  DropdownMenuItem(value:choice,child:Text(choice))],
                onChanged:(v){if(v!=null)setState(()=>physicsHotkeys[name]=v);},
              )),
              const SizedBox(width:8),
              Switch.adaptive(
                key:ValueKey('cat-physics-hotkey-enabled-'+name),
                value:physicsHotkeyEnabled[name]!,
                onChanged:(v)=>setState(()=>physicsHotkeyEnabled[name]=v)),
              const Text('快捷键',style:TextStyle(fontSize:11)),
            ]),
          ],
        )),
        const SizedBox(height:10),
      ],
      Text('实际 Physics 组由导入模型的物理文件动态发现；本示例模型不声明 Physics 文件。',
        style:TextStyle(color:cs.onSurfaceVariant,fontSize:11)),
    ]);
  }
  Widget _stat(String label,String value){
    final cs=Theme.of(context).colorScheme;
    return Column(mainAxisSize:MainAxisSize.min,children:[
      Text(value,style:TextStyle(fontSize:18,
        fontWeight:FontWeight.w800,color:cs.primary)),
      Text(label,style:TextStyle(fontSize:10,color:cs.onSurfaceVariant)),
    ]);
  }


  Widget _diagnostics(){
    final cs=Theme.of(context).colorScheme;
    final snapshot={
      'source':'Axon-Input bundled keyboard-cat sample',
      'uiOnly':true,
      'active':active,
      'activeAction':activeToken,
      'previewCount':previewCount,
      'bindings':bindings,
      'modes':actionModes,
      'parameterOverrides':overrides,
      'parameterLocks':{
        for(final e in locks.entries)
          if(e.value)e.key:overrides[e.key]??.5,
      },
      'expressionWeights':expressionWeights,
      'physics':{
        'globalStrength':globalPhysics,
        'demoGroups':{
          for(final name in physicsStrengths.keys)
            name:{
              'enabled':physicsEnabled[name],
              'strength':physicsStrengths[name],
              'shortcut':physicsHotkeys[name],
              'shortcutEnabled':physicsHotkeyEnabled[name],
            },
        },
      },
    };
    final formatted=const JsonEncoder.withIndent('  ').convert(snapshot);
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      _heading('调试状态与快照','只读 · 内存数据'),
      FlPanel(padding:const EdgeInsets.all(14),child:Column(
        crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('当前状态',style:TextStyle(
            fontWeight:FontWeight.w700,color:cs.onSurface)),
          const SizedBox(height:10),
          Wrap(spacing:8,runSpacing:8,children:[
            _stateTag('当前动作',activeToken),
            _stateTag('功能绑定',bindings.length.toString()),
            _stateTag('参数覆盖',overrides.length.toString()),
            _stateTag('锁定参数',
              locks.values.where((v)=>v).length.toString()),
          ]),
          const SizedBox(height:13),
          const Text('内存状态 JSON（仅预览，不导出到文件）',
            style:TextStyle(fontSize:12,fontWeight:FontWeight.w600)),
          const SizedBox(height:7),
          Container(
            key:const ValueKey('cat-debug-json'),
            constraints:const BoxConstraints(maxHeight:230),
            width:double.infinity,
            padding:const EdgeInsets.all(10),
            decoration:BoxDecoration(
              color:cs.surfaceContainerHigh,
              borderRadius:BorderRadius.circular(12)),
            child:SingleChildScrollView(child:SelectableText(
              formatted,style:TextStyle(fontFamily:'monospace',
                fontSize:11,color:cs.onSurface))),
          ),
        ],
      )),
      const SizedBox(height:9),
      Text('本面板不是运行时遥测；不会保存、读取或上传真实配置。',
        style:TextStyle(color:cs.onSurfaceVariant,fontSize:11)),
    ]);
  }
  Widget _stateTag(String label,String value){
    final cs=Theme.of(context).colorScheme;
    return Container(
      padding:const EdgeInsets.symmetric(horizontal:10,vertical:8),
      decoration:BoxDecoration(color:cs.surfaceContainerHigh,
        borderRadius:BorderRadius.circular(10)),
      child:Text(label+'：'+value,
        style:TextStyle(color:cs.onSurface,fontSize:11)),
    );
  }

  Widget _heading(String title,String subtitle){
    final cs=Theme.of(context).colorScheme;
    return Padding(padding:const EdgeInsets.fromLTRB(2,6,2,12),
      child:Row(children:[
        Expanded(child:Text(title,style:TextStyle(
          color:cs.onSurface,fontWeight:FontWeight.w700,fontSize:16))),
        Text(subtitle,style:TextStyle(
          color:cs.onSurfaceVariant,fontSize:11)),
      ]));
  }
}
