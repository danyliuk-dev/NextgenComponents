# Подключение и общие правила

[Оглавление](README.md)

## Blazor

Требуется .NET 10. Добавьте ProjectReference на `src/NextgenComponents.Blazor/NextgenComponents.Blazor.csproj`, namespace `NextgenComponents.Blazor` в `_Imports.razor` и CSS:

```html
<link rel="stylesheet" href="_content/NextgenComponents.Blazor/nextgen.css" />
```

Пример интерактивной страницы:

```razor
@page "/example"
@using NextgenComponents.Blazor
@using static Microsoft.AspNetCore.Components.Web.RenderMode
@rendermode InteractiveServer
<div class="ng-scope" data-ng-theme="light" data-ng-density="normal">
    <NgTextBox Label="Имя" @bind-Value="name" />
    <NgButton Primary OnClick="Save">Сохранить</NgButton>
    <p>@status</p>
</div>
@code {
    private string? name;
    private string? status;
    private void Save() => status = $"Привет, {name}";
}
```

Хост должен регистрировать `AddRazorComponents().AddInteractiveServerComponents()` и `MapRazorComponents<App>().AddInteractiveServerRenderMode()`. В приложении с глобальным интерактивным режимом дополнительный `@rendermode` страницы не нужен. Статический SSR показывает HTML, но сам по себе не выполняет callback браузера.

`@bind-Value` связывает `Value`, `ValueChanged` и `ValueExpression`. Если используете ручные `Value` и `ValueChanged`, для полей InputBase и компонентов с InputSelect/InputNumber передавайте `ValueExpression="()=>model.Field"`. Это требуется и вне формы. Для строковых параметров используйте `Value="@variable"`: `Value="variable"` может означать буквальный текст, а не переменную.

`data-ng-theme` принимает `light`/`dark`, `data-ng-density` — `normal`/`compact`. Применяйте их к внешнему `.ng-scope`. Не переопределяйте цвета отдельных компонентов без необходимости: это нарушает согласованность темы.

## Flutter

Требуются Flutter >= 3.38 и Dart >= 3.10. Добавьте зависимость (путь относительно своего pubspec.yaml):

```yaml
dependencies:
  flutter:
    sdk: flutter
  nextgen_components:
    path: ../../packages/nextgen_components
```

Выполните `flutter pub get`. Минимальный пример:

```dart
import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() => runApp(MaterialApp(
  theme: NgTheme.light(), darkTheme: NgTheme.dark(),
  home: const Demo(),
));
class Demo extends StatefulWidget {
  const Demo({super.key});
  @override State<Demo> createState() => _DemoState();
}
class _DemoState extends State<Demo> {
  bool enabled = true;
  @override Widget build(BuildContext context) => Scaffold(
    body: Padding(padding: const EdgeInsets.all(24), child: NgSwitch(
      label: 'Уведомления', value: enabled,
      onChanged: (v) => setState(() => enabled = v),
    )),
  );
}
```

`NgTheme.light(compact: true)` и `NgTheme.dark(compact: true)` включают компактную плотность. Примеры Flutter на страницах компонентов вставляются в тело класса State, как `_DemoState` выше; методы `build` не складываются вместе. Импорт Material предоставляет Text, Widget, BuildContext и остальные стандартные типы.

Большинство компонентов управляются родителем: `value` → пользовательское действие → `onChanged` → `setState` → новое `value`. Если callback не сохраняет значение, интерфейс возвращается к старому состоянию. У текстовых полей `initialValue` — только начальное значение. Для программного сброса используйте `TextEditingController`; не передавайте controller и initialValue одновременно, освобождайте controller в dispose.

## Формы, коллекции и сохранение

1. Держите редактируемый черновик отдельно от сохранённой записи.
2. Оборачивайте поля в NgForm. У Blazor правила DataAnnotations находятся в модели; у Flutter используйте validator/required.
3. При успешной проверке вызывайте собственный сервис сохранения. Ошибки сети не являются ошибками парсинга поля — показывайте их отдельно.
4. При Cancel отбросьте черновик. После Save замените элемент и коллекцию, чтобы таблицы пересчитались.
5. Не меняйте входные списки и наборы «на месте» без уведомления; принимайте новые коллекции из callback. ID записей и дерева должны быть стабильными и уникальными.

Даты представлены различными типами: Blazor DateOnly/TimeOnly/DateTime, Flutter DateTime/TimeOfDay. Нормализуйте часовые пояса на границе приложения. Компоненты не являются timezone-сервисом.

## Запуск и проверенные сценарии

Из корня: `dotnet run --project examples/BlazorGallery --urls http://127.0.0.1:5180`.
Во Flutter-галерее: `flutter run -d chrome --web-port 5181`.

| Раздел | Blazor | Flutter |
|---|---|---|
| Базовые элементы | `/` | Foundation |
| Форма бронирования | `/forms` | Forms and dates |
| Таблицы и дерево | `/data` | Data workspace |
| Диаграммы и события | `/analytics` | Analytics and schedule |
| Лист и сводная таблица | `/workbook` | Workbook |

Сначала проверяйте пустое/некорректное значение, callback, исправление ошибки, смену темы и узкий контейнер. Текущее подтверждение относится к Web в видимом Chrome на Linux iMac. Нативные мобильные платформы будут проверяться отдельно. Матрица ограничений и реальные результаты находятся в [verification](../verification.md).
