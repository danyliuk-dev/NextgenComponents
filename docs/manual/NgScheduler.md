# NgScheduler — Недельное расписание

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Показывает события по дням недели и вызывает приложение для создания/редактирования.

## Поведение и практические правила

Начало недели — понедельник. Предыдущая/следующая неделя и Today вызывают callback изменения даты. События имеют уникальный Id/id, непустой Title/title и End/end строго позже Start/start. Пересечение полуночи отображается в обоих днях; конец ровно в 00:00 не добавляет запись следующего дня. Редактор и хранение создаёт приложение: полный Save/Cancel/Delete есть в Analytics gallery. Используются локальные wall-clock значения без конвертации timezone. Это дневные карточки недели, не почасовая сетка. Повторы, ресурсы и drag/drop не реализованы.

## Blazor: рабочий пример

```razor
<NgScheduler @bind-Date="week" Items="events" OnCreate="day=>message=day.ToShortDateString()" OnEdit="item=>message=item.Title"/>
<p>@message</p>
@code { private DateTime week=new(2026,10,19); private string? message; private NgScheduleEvent[] events=[new("a","Встреча",new(2026,10,19,10,0,0),new(2026,10,19,11,0,0))]; }
```

## Flutter: рабочий пример

```dart
DateTime week = DateTime(2026,10,19);
Widget build(BuildContext context) => NgScheduler(date: week,
  items: [NgScheduleEvent('a','Встреча',DateTime(2026,10,19,10),DateTime(2026,10,19,11))],
  onDateChanged: (v) => setState(() => week = v),
  onCreate: (day) => debugPrint('Добавить $day'),
  onEdit: (item) => debugPrint(item.title));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Label` | `string` | "Schedule" | Подпись элемента или доступное имя. |
| `Date` | `DateTime` | DateTime.Today | Любая дата отображаемой недели. |
| `DateChanged` | `EventCallback<DateTime>` | не задан | Новая дата после навигации недели. |
| `Items` | `IReadOnlyList<NgScheduleEvent>` | [] | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `OnCreate` | `EventCallback<DateTime>` | не задан | Выбранный день для создания события; откройте свой редактор. |
| `OnEdit` | `EventCallback<NgScheduleEvent>` | не задан | Выбранное событие для редактирования. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `label` | `String` | Подпись элемента или доступное имя. |
| `date` | `DateTime` | Любая дата отображаемой недели. |
| `items` | `List<NgScheduleEvent>` | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `onDateChanged` | `ValueChanged<DateTime>` | Новая дата после навигации недели. |
| `onCreate` | `ValueChanged<DateTime>` | Выбранный день для создания события; откройте свой редактор. |
| `onEdit` | `ValueChanged<NgScheduleEvent>` | Выбранное событие для редактирования. |

```dart
const NgScheduler({
    super.key,
    this.label = 'Schedule',
    required this.date,
    required this.items,
    required this.onDateChanged,
    required this.onCreate,
    required this.onEdit,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgScheduler.razor)
- [Flutter](../../packages/nextgen_components/lib/src/visualization.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
