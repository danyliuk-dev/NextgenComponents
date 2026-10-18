# NgComboBox — Выбор с поиском

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Выбор одного значения из набора NgOption; Value/value содержит ключ, Label/label — отображаемую подпись.

## Поведение и практические правила

Ключи вариантов должны быть уникальны. Disabled у NgOption исключает выбор этого пункта. ComboBox фильтрует варианты по тексту; произвольная строка не становится допустимым ключом. Некорректный черновик блокирует форму; required во Flutter запрещает пустой выбор. Локальный список; удалённый поиск, виртуализация и группировка не реализованы.

## Blazor: рабочий пример

```razor
<NgComboBox Label="Команда" Items="options" @bind-Value="team"/>
@code { private string? team="design"; private NgOption[] options=[new("design","Дизайн"),new("dev","Разработка"),new("locked","Недоступно",true)]; }
```

## Flutter: рабочий пример

```dart
String? team = 'design';
Widget build(BuildContext context) => NgComboBox(label: 'Команда', value: team,
  items: const [NgOption('design','Дизайн'), NgOption('dev','Разработка'),
    NgOption('locked','Недоступно', disabled: true)],
  onChanged: (v) => setState(() => team = v));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Id` | `string` | "ng-"+Guid.NewGuid().ToString("N") | Уникальный HTML ID; по умолчанию генерируется. |
| `Label` | `string` | "Choose an option" | Подпись элемента или доступное имя. |
| `Items` | `IReadOnlyList<NgOption>` | [] | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `Disabled` | `bool` | false | true запрещает действия пользователя. |
| `Value` | `string?` | значение модели | Текущее значение поля. |
| `ValueChanged` | `EventCallback<string?>` | — | Изменение значения. |
| `ValueExpression` | `Expression<Func<string?>>` | обязательно | Автоматически создаётся @bind-Value; при ручной привязке передайте явно. |
| `AdditionalAttributes` | словарь HTML-атрибутов | null | Дополнительные HTML/ARIA атрибуты поля. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `label` | `String` | Подпись элемента или доступное имя. |
| `value` | `String?` | Текущее значение; тип и правила описаны выше. |
| `items` | `List<NgOption>` | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `onChanged` | `ValueChanged<String?>?` | Новое значение для родителя; обновите состояние через setState. |
| `enabled` | `bool` | false запрещает действия пользователя. |
| `required` | `bool` | true требует непустое значение при проверке формы. |

```dart
const NgComboBox({
    super.key,
    this.label = 'Choose an option',
    required this.value,
    required this.items,
    this.onChanged,
    this.enabled = true,
    this.required = false,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgComboBox.razor)
- [Flutter](../../packages/nextgen_components/lib/src/forms.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
