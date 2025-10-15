# 📱 Barcode Scanner (SwiftUI + UIKit)

iOS приложение для сканирования штрих-кодов EAN-8 и EAN-13 с использованием камеры устройства. Демонстрирует интеграцию UIKit компонентов в SwiftUI через `UIViewControllerRepresentable` и работу с AVFoundation.

---

## 🔍 Что делает приложение

- Захватывает видео с камеры и распознаёт штрих-коды форматов **EAN-8** и **EAN-13**
- Отображает отсканированный код на экране с цветовой индикацией (красный/зелёный)
- Показывает понятные алерты при ошибках (нет доступа к камере / неверный формат)
- Использует архитектуру **MVVM** с Delegate pattern для связи UIKit ↔ SwiftUI

---

## 🧱 Архитектура (MVVM + Coordinator)

**Model** - данные и их структура (`CameraError`, `AlertItem`)  
**View** - SwiftUI экраны (`BarcodeScannerView`, `ScannerView`)  
**ViewModel** - управление состоянием (`BarcodeScannerViewModel`)  
**Coordinator** - мост между UIKit и SwiftUI (`ScannerView.Coordinator`)

### Как это работает:

1. Пользователь запускает приложение
2. `ScannerViewController` (UIKit) настраивает `AVCaptureSession` и начинает захват с камеры
3. Когда баркод распознан, `AVCaptureMetadataOutputObjectsDelegate` получает данные
4. Делегат вызывает `Coordinator`, который обновляет `@Published` свойства в `ViewModel`
5. SwiftUI автоматически обновляет UI (показывает код или алерт)

---

## 🔄 Цепочка событий «Камера → Баркод → UI»

1. `AVCaptureSession` захватывает видео с камеры
2. `AVCaptureMetadataOutput` обнаруживает баркод
3. `metadataOutput(_:didOutput:)` вызывается с данными баркода
4. Через делегат → `Coordinator` → устанавливается `scannedCode` в ViewModel
5. `@Published` триггерит обновление, SwiftUI показывает код на экране

При ошибках (нет камеры / неверный формат) аналогично через делегат устанавливается `alertItem`, и SwiftUI показывает `.alert()`.

Важно: все изменения состояния обёрнуты в `DispatchQueue.main.async` для предотвращения "Modifying state during view update".

---

## ▶️ Как запустить

### Требования:
- Xcode 16.2+
- iOS 18.2+
- **Физическое устройство** (симулятор не имеет камеры!)

### Шаги:
1. Клонируйте репозиторий
   ```bash
   git clone <repository-url>
   cd Barcode-Scanner
   ```
2. Откройте `BarcodeScanner.xcodeproj`
3. Подключите iPhone/iPad
4. Выберите устройство и запустите (⌘R)

> 💡 При первом запуске система запросит разрешение на доступ к камере

---

## 🧰 Технологии

- **Swift 5.0**
- **SwiftUI** - декларативный UI, `@StateObject`, `@Published`, `@Binding`
- **UIKit** - `UIViewController`, `UIViewControllerRepresentable`
- **AVFoundation** - `AVCaptureSession`, `AVCaptureMetadataOutput`, `AVCaptureVideoPreviewLayer`
- **Delegate Pattern** - для передачи событий из UIKit в SwiftUI
- **Concurrency** - `DispatchQueue` для управления потоками

---

## 🎯 Ключевые концепции

### 1. UIViewControllerRepresentable
Протокол для интеграции UIKit контроллера в SwiftUI:
```swift
struct ScannerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ScannerViewController
    func updateUIViewController(...)
    func makeCoordinator() -> Coordinator
}
```

### 2. Coordinator Pattern
`Coordinator` выступает делегатом для UIKit компонента и обновляет SwiftUI состояние.

### 3. AVFoundation для баркодов
- `AVCaptureDevice` - доступ к камере
- `AVCaptureMetadataOutput` - распознавание кодов (EAN-8, EAN-13)
- `metadataObjectTypes` - список поддерживаемых форматов

### 4. Thread Safety
Изменения `@Published` свойств всегда в main thread через `DispatchQueue.main.async`.

---

## 🗺️ Идеи для развития

- [ ] Визуальная рамка области сканирования с анимацией
- [ ] Кнопка "Scan Again" для повторного сканирования
- [ ] Поддержка QR-кодов и других форматов (Code 128, PDF417)
- [ ] История отсканированных кодов с возможностью копирования
- [ ] Haptic feedback при успешном сканировании
- [ ] Проверка разрешений камеры с UI для настроек
- [ ] Фонарик для сканирования в темноте
- [ ] Поделиться баркодом (share sheet)
- [ ] Unit тесты для ViewModel
- [ ] Локализация (EN/RU)

---

## 🙏 Благодарности

Проект создан на основе обучающего туториала от **Sean Allen**. Материал был адаптирован и дополнен для изучения интеграции SwiftUI и UIKit, работы с AVFoundation и архитектурных паттернов.

---

**Happy Scanning! 📲**
