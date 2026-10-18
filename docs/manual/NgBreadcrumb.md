# NgBreadcrumb — Навигационная цепочка

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Показывает путь к текущему разделу и даёт перейти к предкам.

## Поведение и практические правила

Последний элемент — текущая страница, он не является кнопкой перехода. Callback возвращает Id выбранного предка. Приложение само меняет маршрут или фильтр. Id должен быть стабильным, подпись можно локализовать. Компонент не строит цепочку из URL автоматически.

## Blazor: рабочий пример

```razor
<NgBreadcrumb Items="items" OnNavigate="id=>selected=id"/>
<p>@selected</p>
@code { private string? selected; private NgBreadcrumbItem[] items=[new("all","Проекты"),new("design","Дизайн")]; }
```

## Flutter: рабочий пример

```dart
String? selected;
Widget build(BuildContext context) => NgBreadcrumb(
  items: const [NgBreadcrumbItem('all','Проекты'),NgBreadcrumbItem('design','Дизайн')],
  onNavigate: (id) => setState(() => selected = id));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Label` | `string` | "Breadcrumb" | Подпись элемента или доступное имя. |
| `Items` | `IReadOnlyList<NgBreadcrumbItem>` | [] | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `OnNavigate` | `EventCallback<string>` | не задан | ID выбранного предка. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `items` | `List<NgBreadcrumbItem>` | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `onNavigate` | `ValueChanged<String>` | ID выбранного предка. |

```dart
const NgBreadcrumb({
    super.key,
    required this.items,
    required this.onNavigate,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgBreadcrumb.razor)
- [Flutter](../../packages/nextgen_components/lib/src/data.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
