# NgDataGrid — Таблица записей

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Локальная таблица с числовой сортировкой, поиском, пагинацией и выбором строк.

## Поведение и практические правила

RowId/rowId должен возвращать уникальный постоянный ключ. Колонка Value/value возвращает исходный тип (число для числовой сортировки); Format/format меняет только представление. Поиск применяется до пагинации. Выбор хранится по ID и сохраняется между страницами; select-page выбирает только текущую страницу. RowActions/rowActions и Toolbar/toolbar позволяют добавить действия; редактор записи создаёт приложение. После CRUD заменяйте список, а не меняйте объект без уведомления. Серверная пагинация, виртуализация, группировка и Excel-экспорт пока отсутствуют.

## Blazor: рабочий пример

```razor
<NgDataGrid TItem="Product" Items="rows" Columns="columns" RowId="r=>r.Id" @bind-SelectedIds="selected"/>
@code { public record Product(string Id,string Name,int Count); private Product[] rows=[new("a","Стол",12),new("b","Стул",120)]; private HashSet<string> selected=[]; private NgDataColumn<Product>[] columns=[new("name","Название",r=>r.Name),new("count","Количество",r=>r.Count)]; }
```

## Flutter: рабочий пример

```dart
final rows = [(id: 'a', name: 'Стол', count: 12), (id: 'b', name: 'Стул', count: 120)];
Set<String> selected = {};
Widget build(BuildContext context) => NgDataGrid<({String id, String name, int count})>(
  items: rows, rowId: (r) => r.id, selectedIds: selected,
  onSelectionChanged: (v) => setState(() => selected = v),
  columns: [NgDataColumn('name','Название',(r) => r.name),
    NgDataColumn('count','Количество',(r) => r.count)]);
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Items` | `IReadOnlyList<TItem>` | обязательный | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `Columns` | `IReadOnlyList<NgDataColumn<TItem>>` | обязательный | Описание колонок либо поле измерения; см. модель и пример. |
| `RowId` | `Func<TItem,string>` | обязательный | Функция уникального стабильного ключа записи. |
| `Label` | `string` | "Records" | Подпись элемента или доступное имя. |
| `EmptyText` | `string` | "No matching records." | Сообщение для пустого результата. |
| `Selectable` | `bool` | true | Показывать выбор строк. |
| `SelectedIds` | `HashSet<string>` | [] | Набор выбранных ID. |
| `SelectedIdsChanged` | `EventCallback<HashSet<string>>` | не задан | Новый набор выбранных ID. |
| `Toolbar` | `RenderFragment?` | не задан | Пользовательская панель действий. |
| `RowActions` | `RenderFragment<TItem>?` | не задан | Шаблон действий для конкретной записи. |
| `InitialPageSize` | `int` | 5 | Начальный размер страницы при создании компонента. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `items` | `List<T>` | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `columns` | `List<NgDataColumn<T>>` | Описание колонок либо поле измерения; см. модель и пример. |
| `rowId` | `String Function(T)` | Функция уникального стабильного ключа записи. |
| `selectedIds` | `Set<String>` | Набор выбранных ID. |
| `onSelectionChanged` | `ValueChanged<Set<String>>?` | Новый набор выбранных ID. |
| `rowActions` | `Widget Function(BuildContext, T)?` | Шаблон действий для конкретной записи. |
| `toolbar` | `Widget?` | Пользовательская панель действий. |
| `label` | `String` | Подпись элемента или доступное имя. |
| `emptyText` | `String` | Сообщение для пустого результата. |
| `initialPageSize` | `int` | Начальный размер страницы при создании компонента. |

```dart
const NgDataGrid({
    super.key,
    required this.items,
    required this.columns,
    required this.rowId,
    this.selectedIds = const {},
    this.onSelectionChanged,
    this.rowActions,
    this.toolbar,
    this.label = 'Records',
    this.emptyText = 'No matching records.',
    this.initialPageSize = 5,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgDataGrid.razor)
- [Flutter](../../packages/nextgen_components/lib/src/data.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
