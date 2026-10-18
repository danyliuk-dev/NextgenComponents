# NgChart — Диаграмма

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Сравнение категорий и серий; шесть режимов: column, bar, line, area, pie, donut.

## Поведение и практические правила

Число Values/values в каждой серии должно совпадать с Categories/categories. null создаёт разрыв линии; NaN/Infinity не допускаются. Pie/Donut принимают одну неотрицательную серию; нулевой итог показывает пустое состояние. Легенда скрывает серию; callback точки содержит индекс и имя категории/серии и число. Для клавиатуры используйте Chart data (в Blazor также SVG-точки Enter/Space). В Flutter прямой клик canvas и доступные кнопки списка разделены. Стэкинг, zoom, export и автоматическая раскладка длинных подписей отсутствуют.

## Blazor: рабочий пример

```razor
<NgChart Title="Продажи" Kind="NgChartKind.Line" Categories="categories" Series="series" OnPointSelected="p=>selected=p.Label"/>
<p>@selected</p>
@code { private string? selected; private string[] categories=["Пн","Вт","Ср"]; private NgChartSeries[] series=[new("Заказы",[10,null,25])]; }
```

## Flutter: рабочий пример

```dart
String? selected;
Widget build(BuildContext context) => NgChart(title: 'Продажи', kind: NgChartKind.line,
  categories: const ['Пн','Вт','Ср'], series: const [NgChartSeries('Заказы',[10,null,25])],
  onPointSelected: (p) => setState(() => selected = p.label));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Title` | `string` | "Chart" | Заголовок блока или окна. |
| `Kind` | `NgChartKind` | NgChartKind.Column | Режим диаграммы NgChartKind. |
| `Categories` | `IReadOnlyList<string>` | [] | Подписи категорий в порядке значений. |
| `Series` | `IReadOnlyList<NgChartSeries>` | [] | Набор NgChartSeries с равным категориям числом значений. |
| `OnPointSelected` | `EventCallback<NgChartSelection>` | не задан | Выбранная точка NgChartSelection. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `title` | `String` | Заголовок блока или окна. |
| `kind` | `NgChartKind` | Режим диаграммы NgChartKind. |
| `categories` | `List<String>` | Подписи категорий в порядке значений. |
| `series` | `List<NgChartSeries>` | Набор NgChartSeries с равным категориям числом значений. |
| `onPointSelected` | `ValueChanged<NgChartSelection>?` | Выбранная точка NgChartSelection. |

```dart
const NgChart({
    super.key,
    this.title = 'Chart',
    this.kind = NgChartKind.column,
    required this.categories,
    required this.series,
    this.onPointSelected,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgChart.razor)
- [Flutter](../../packages/nextgen_components/lib/src/visualization.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
