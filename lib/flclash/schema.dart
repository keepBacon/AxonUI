import 'package:flutter/material.dart';
import 'controls.dart';
import 'theme.dart';

/// Pure UI renderer for Axon's declarative schema; never invokes input APIs.
/// Supported: toggle, button, slider, number, select, text, key, binding,
/// color and nested list. All output is local UI state.
class FlSchemaPanel extends StatefulWidget {
  const FlSchemaPanel({super.key, required this.features});
  final List<Map<String, dynamic>> features;
  @override
  State<FlSchemaPanel> createState()=>_FlSchemaPanelState();
}
class _FlSchemaPanelState extends State<FlSchemaPanel> {
  final Map<String,Object?> _values={};
  @override
  Widget build(BuildContext context) => Column(children:[
    for(final feature in widget.features) ...[
      FlSection(title: '${feature['name']??'未命名'}', icon: Icons.widgets_outlined),
      FlGroup(children: [
        if(feature['type']=='button')
          FlSettingRow(title: feature['buttonText']?.toString() ?? '运行预览',
            subtitle:'仅展示点击反馈，不执行插件动作',
            trailing:const Icon(Icons.chevron_right_rounded),
            onTap:(){ ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content:Text('UI 预览：没有执行任何输入动作'))); })
        else FlToggleRow(title:'在界面中显示',
          value:(_values['${feature['id']}.enabled']??feature['default']??false)==true,
          onChanged:(v)=>setState(()=>_values['${feature['id']}.enabled']=v)),
      ]),
      const SizedBox(height:12),
      for(final raw in (feature['debug'] is List ? feature['debug'] as List : const []))
        if (raw is Map) Padding(padding: const EdgeInsets.only(bottom: 12),
          child:_field(Map<String,dynamic>.from(raw),'${feature['id']}')),
    ]
  ]);

  Widget _field(Map<String,dynamic> field,String prefix) {
    final id='$prefix.${field['id']}';
    final title=(field['name']??field['id']??'参数').toString();
    final type=(field['type']??'text').toString();
    final value=_values.containsKey(id)?_values[id]:field['default'];
    void change(Object? next)=>setState(()=>_values[id]=next);
    switch(type){
      case 'toggle':return FlGroup(children:[FlToggleRow(title:title,
        value:value==true,onChanged:change)]);
      case 'slider':case 'number':
        final min=(field['min'] is num?(field['min'] as num).toDouble():0.0);
        final max=(field['max'] is num?(field['max'] as num).toDouble():100.0);
        final n=value is num?value.toDouble():min;
        return FlSliderPanel(title:title,value:n.clamp(min,max>min?max:min+1).toDouble(),
          min:min,max:max>min?max:min+1,divisions:null,
          suffix:(field['suffix']??'').toString(),onChanged:change);
      case 'select':
        final options=(field['options'] is List ? field['options'] as List : const [])
          .map((e)=>e.toString()).toList();
        if(options.isEmpty)return const SizedBox.shrink();
        final selected=options.contains(value?.toString())?value.toString():options.first;
        return FlGroup(children:[FlSettingRow(title:title,subtitle:selected,
          trailing:const Icon(Icons.chevron_right),onTap:()async{
            final picked=await flPick<String>(context,title:title,values:options,
              label:(v)=>v,selected:selected);
            if(picked!=null)change(picked);
          })]);
      case 'text':return FlPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,
        children:[Text(title,style:const TextStyle(fontSize:16)),const SizedBox(height:10),
          TextFormField(key:ValueKey(id),initialValue:value?.toString()??'',
            decoration:InputDecoration(hintText:title),onChanged:change)]));
      case 'key':
        final key=value is num?value.toInt():-1;
        return FlGroup(children:[FlSettingRow(title:title,
          subtitle:'仅预览键码，不捕获或发送实际按键',
          trailing:FlStepCounter(value:key,min:-1,max:999,onChanged:change))]);
      case 'binding':
        final map=value is Map?Map<String,dynamic>.from(value):<String,dynamic>{};
        final source=(map['source']??'touch').toString();
        return FlPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          Text(title,style:const TextStyle(fontWeight:FontWeight.w600,fontSize:17)),
          const SizedBox(height:10),FlSegmented<String>(values:const ['touch','key'],
            label:(v)=>v=='touch'?'触控预览':'按键预览',value:source=='key'?'key':'touch',
            onChanged:(v)=>change({...map,'source':v})),
          const SizedBox(height:10),Text('仅用于布局显示；未接入任何输入接口',
            style:TextStyle(color:flMuted(context))),
        ]));
      case 'color':
        final samples=[FlTokens.blue,const Color(0xFF5F9BCB),
          const Color(0xFF68BBA9),const Color(0xFFAA8FDF),const Color(0xFFD2A5A0)];
        final initial=value is int?Color(value):FlTokens.blue;
        return FlPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,
          children:[Text(title,style:const TextStyle(fontSize:17)),
            const SizedBox(height:10),FlColorSwatches(colors:samples,value:initial,
              onChanged:(v)=>change(v.toARGB32()))]));
      case 'list':
        final rows=value is List?List<Map<String,dynamic>>.from(
          value.whereType<Map>().map((e)=>Map<String,dynamic>.from(e))):<Map<String,dynamic>>[];
        final specs=field['fields'] is List?(field['fields'] as List).whereType<Map>()
          .map((e)=>Map<String,dynamic>.from(e)).toList():<Map<String,dynamic>>[];
        return FlPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          Row(children:[Expanded(child:Text(title,style:const TextStyle(fontSize:17))),
            IconButton.filledTonal(tooltip:'添加条目',onPressed:rows.length>=16?null:(){
              change([...rows,{for(final f in specs) f['id'].toString():f['default']}]);
            },icon:const Icon(Icons.add_rounded))]),
          for(var i=0;i<rows.length;i++)Padding(padding:const EdgeInsets.only(top:8),
            child:FlGroup(children:[FlSettingRow(title:'条目 ${i+1}',
              subtitle:rows[i].values.map((e)=>e.toString()).join(' · '),
              trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:(){
                final next=[...rows]..removeAt(i);change(next);
              }),onTap:()async{
                if(specs.isEmpty)return;
                final entry=rows[i];
                final options=specs.where((f)=>f['type']=='select').toList();
                if(options.isNotEmpty){final field=options.first;
                  final choices=(field['options'] as List).map((x)=>x.toString()).toList();
                  final selected=entry[field['id']]?.toString()??choices.first;
                  final result=await flPick<String>(context,title:field['name'].toString(),
                    values:choices,label:(e)=>e,selected:selected);
                  if(result!=null){final next=[...rows];next[i]={...entry,field['id'].toString():result};
                    change(next);}
                }
              })])),
          if(rows.isEmpty)Text('暂无条目',style:TextStyle(color:flMuted(context))),
        ]));
      default:return FlGroup(children:[FlSettingRow(title:title,subtitle:'暂不支持：$type')]);
    }
  }
}
