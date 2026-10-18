# NgPivotGrid — Сводная таблица

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Группировка числовой меры по двум измерениям с итогами и просмотром исходных строк.

## Поведение и практические правила

NgPivotRecord содержит уникальный ID, словарь строковых измерений и одну числовую Value/value (может быть null). Измерения сортируются по строковым ключам; отсутствующий ключ отображается как (blank). Sum/Average/Min/Max используют только числа; Count считает исходные записи, включая null. Все итоги считаются заново по исходным записям: среднее не является средним средних. Callback ячейки/итога отдаёт оригинальные записи; null Row/Column обозначает итог, пустая строка — пустое измерение. Фильтры применяйте к Items/items до передачи компоненту. Множественные уровни, несколько мер, OLAP и drag/drop конфигуратора отсутствуют.

## Blazor: рабочий пример

```razor
<NgPivotGrid Items="records" RowField="Team" ColumnField="Quarter" Aggregate="NgAggregate.Average" OnCellSelected="p=>count=p.Records.Count"/>
<p>Исходных строк: @count</p>
@code { private int count; private NgPivotRecord[] records=[new("a",new Dictionary<string,string>{{"Team","Design"},{"Quarter","Q1"}},100),new("b",new Dictionary<string,string>{{"Team","Design"},{"Quarter","Q1"}},200)]; }
```

## Flutter: рабочий пример

```dart
int count = 0;
Widget build(BuildContext context) => NgPivotGrid(rowField: 'Team', columnField: 'Quarter',
  aggregate: NgAggregate.average, items: [
    NgPivotRecord('a', {'Team':'Design','Quarter':'Q1'},100),
    NgPivotRecord('b', {'Team':'Design','Quarter':'Q1'},200)],
  onCellSelected: (p) => setState(() => count = p.records.length));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Label` | `string` | "Pivot table" | Подпись элемента или доступное имя. |
| `Items` | `IReadOnlyList<NgPivotRecord>` | [] | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `RowField` | `string` | "Team" | Ключ строкового измерения в Dimensions/dimensions. |
| `ColumnField` | `string` | "Quarter" | Ключ столбцового измерения. |
| `Aggregate` | `NgAggregate` | NgAggregate.Sum | Sum, Count, Average, Min или Max. |
| `OnCellSelected` | `EventCallback<NgPivotSelection>` | не задан | Измерения и исходные записи выбранной ячейки/итога. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `label` | `String` | Подпись элемента или доступное имя. |
| `rowField` | `String` | Ключ строкового измерения в Dimensions/dimensions. |
| `columnField` | `String` | Ключ столбцового измерения. |
| `items` | `List<NgPivotRecord>` | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `aggregate` | `NgAggregate` | Sum, Count, Average, Min или Max. |
| `onCellSelected` | `ValueChanged<NgPivotSelection>?` | Измерения и исходные записи выбранной ячейки/итога. |

```dart
const NgPivotGrid({
    super.key,
    this.label = 'Pivot table',
    required this.items,
    this.rowField = 'Team',
    this.columnField = 'Quarter',
    this.aggregate = NgAggregate.sum,
    this.onCellSelected,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgPivotGrid.razor)
- [Flutter](../../packages/nextgen_components/lib/src/workbook.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
