# NgNotification — Уведомление

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Сообщение о результате операции с возможностью скрытия.

## Поведение и практические правила

Blazor: Visible управляет показом, Tone="error" включает ошибку. Flutter: error: true задаёт ошибочный результат; видимость управляется условием родителя. Callback onDismiss/VisibleChanged должен убрать сообщение из интерфейса. Автоматического таймера, очереди toast и сетевого повтора нет. Не используйте уведомление как единственное место отображения ошибки поля.

## Blazor: рабочий пример

```razor
<NgNotification @bind-Visible="visible" Tone="success">Сохранено</NgNotification>
@code { private bool visible=true; }
```

## Flutter: рабочий пример

```dart
bool visible = true;
Widget build(BuildContext context) => visible ? NgNotification(message: 'Сохранено',
  onDismiss: () => setState(() => visible = false)) : const SizedBox.shrink();
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Visible` | `bool` | true | Видимость уведомления. |
| `VisibleChanged` | `EventCallback<bool>` | не задан | Обновление видимости после закрытия. |
| `Tone` | `string` | "success" | Стиль уведомления, например success или error. |
| `ChildContent` | `RenderFragment?` | не задан | Содержимое Razor-компонента. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `message` | `String` | Текст уведомления. |
| `onDismiss` | `VoidCallback?` | Запрос убрать уведомление. |
| `error` | `bool` | true включает оформление ошибки. |

```dart
const NgNotification({
    super.key,
    required this.message,
    this.onDismiss,
    this.error = false,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgNotification.razor)
- [Flutter](../../packages/nextgen_components/lib/src/components.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
