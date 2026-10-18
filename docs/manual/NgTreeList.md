# NgTreeList — Дерево с колонками

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Иерархические данные с раскрытием узлов, поиском и выбором.

## Поведение и практические правила

Все ID должны быть уникальны во всём дереве; циклы/повторные ID недопустимы. ExpandedIds/expandedIds — набор раскрытых ID; сохраняйте его из callback. Поиск сохраняет путь родителей найденного узла. TreeList сортирует внутри уровня, не разрушая иерархию. TreeView имеет клавиатурную навигацию и недоступные узлы; полный аудит screen reader не выполнен. Ленивой загрузки, перетаскивания и виртуализации нет.

## Blazor: рабочий пример

```razor
<NgTreeList TItem="string" Items="nodes" Columns="columns" @bind-ExpandedIds="expanded" @bind-SelectedId="selected"/>
@code { private string? selected; private HashSet<string> expanded=["root"]; private NgTreeNode<string>[] nodes=[new("root","Проекты",[new("a","Дизайн"),new("b","Разработка")])]; private NgDataColumn<string>[] columns=[new("name","Название",s=>s)]; }
```

## Flutter: рабочий пример

```dart
Set<String> expanded = {'root'}; String? selected;
Widget build(BuildContext context) => NgTreeList<String>(
  items: const [NgTreeNode('root','Проекты',children: [NgTreeNode('a','Дизайн'),NgTreeNode('b','Разработка')])],
  columns: [NgDataColumn('name','Название',(s) => s)],
  expandedIds: expanded, selectedId: selected,
  onExpandedChanged: (v) => setState(() => expanded = v),
  onSelected: (v) => setState(() => selected = v));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Label` | `string` | "Hierarchy" | Подпись элемента или доступное имя. |
| `Items` | `IReadOnlyList<NgTreeNode<TItem>>` | [] | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `Columns` | `IReadOnlyList<NgDataColumn<TItem>>` | [] | Описание колонок либо поле измерения; см. модель и пример. |
| `ExpandedIds` | `HashSet<string>` | [] | Набор раскрытых ID дерева. |
| `ExpandedIdsChanged` | `EventCallback<HashSet<string>>` | не задан | Новый набор раскрытых ID. |
| `SelectedId` | `string?` | не задан | ID текущего узла либо null. |
| `SelectedIdChanged` | `EventCallback<string?>` | не задан | Выбор другого узла. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `items` | `List<NgTreeNode<T>>` | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `columns` | `List<NgDataColumn<T>>` | Описание колонок либо поле измерения; см. модель и пример. |
| `expandedIds` | `Set<String>` | Набор раскрытых ID дерева. |
| `onExpandedChanged` | `ValueChanged<Set<String>>` | Новый набор раскрытых ID; сохраните его. |
| `onSelected` | `ValueChanged<String>?` | ID выбранного узла. |
| `selectedId` | `String?` | ID текущего узла либо null. |
| `label` | `String` | Подпись элемента или доступное имя. |

```dart
const NgTreeList({
    super.key,
    required this.items,
    required this.columns,
    required this.expandedIds,
    required this.onExpandedChanged,
    this.onSelected,
    this.selectedId,
    this.label = 'Hierarchy',
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgTreeList.razor)
- [Flutter](../../packages/nextgen_components/lib/src/data.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
