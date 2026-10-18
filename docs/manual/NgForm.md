# NgForm — Форма и валидация

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Объединяет поля, проверяет значения и вызывает обработчик только при успешной проверке.

## Поведение и практические правила

Blazor оборачивает EditForm и DataAnnotationsValidator; Model обязателен, кнопку submit добавляет приложение. Flutter уже добавляет кнопку submitLabel и вызывает Form.validate. Поля должны находиться внутри формы. Для изменения объекта-черновика используйте новый @key/Key, если требуется новый жизненный цикл формы. Межполевые бизнес-правила (например, End > Start) проверяйте в модели или перед сохранением. NgForm не выполняет сохранение в БД автоматически.

## Blazor: рабочий пример

```razor
<NgForm Model="model" OnValidSubmit="Save">
    <NgTextBox Label="Имя" @bind-Value="model.Name"/>
    <NgButton Type="submit" Primary>Сохранить</NgButton>
</NgForm>
<p>@status</p>
@code {
 private Draft model=new(); private string? status;
 private void Save()=>status=$"Сохранено: {model.Name}";
 public class Draft { [System.ComponentModel.DataAnnotations.Required] public string? Name {get;set;} }
}
```

## Flutter: рабочий пример

```dart
String name = '';
Widget build(BuildContext context) => NgForm(submitLabel: 'Сохранить',
  onValidSubmit: () => debugPrint('Сохранено: $name'),
  child: NgTextBox(label: 'Имя', onChanged: (v) => name = v,
    validator: (v) => v == null || v.trim().isEmpty ? 'Введите имя' : null));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Model` | `object` | обязательный | Объект данных для EditForm/DataAnnotations. |
| `Name` | `string` | "ng-form" | Имя формы. |
| `ShowSummary` | `bool` | true | Показывать сводку ошибок. |
| `ChildContent` | `RenderFragment?` | не задан | Содержимое Razor-компонента. |
| `OnValidSubmit` | `EventCallback<EditContext>` | не задан | Вызывается после успешной валидации; сохранение выполняет приложение. |
| `OnInvalidSubmit` | `EventCallback<EditContext>` | не задан | Вызывается при неуспешной проверке формы. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `child` | `Widget` | Дочерний Flutter-виджет. |
| `onValidSubmit` | `VoidCallback` | Вызывается после успешной валидации; сохранение выполняет приложение. |
| `submitLabel` | `String` | Текст встроенной Flutter-кнопки отправки. |
| `formKey` | `GlobalKey<FormState>?` | Необязательный ключ для доступа к FormState. |

```dart
const NgForm({
    super.key,
    required this.child,
    required this.onValidSubmit,
    this.submitLabel = 'Save',
    this.formKey,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgForm.razor)
- [Flutter](../../packages/nextgen_components/lib/src/forms.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
