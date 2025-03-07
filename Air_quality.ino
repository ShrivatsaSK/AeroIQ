#include <WiFi.h>
#include <WebServer.h>

// Replace with your network credentials
const char* ssid = "";
const char* password = "";

// MQ-135 analog input pin
const int mq135Pin = 34;  // GPIO36 (ADC1_CH0)

WebServer server(80);

void setup() {
  Serial.begin(115200);
  
  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  
  Serial.println("Connected to WiFi");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  // Setup server routes
  server.on("/", handleRoot);
  server.on("/data", handleData);

  server.begin();
}

void loop() {
  server.handleClient();
}

void handleRoot() {
  String html = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1'>";
  html += "<style>body {text-align: center; font-family: Arial;}";
  html += ".value {font-size: 3em; color: #1abc9c;}</style></head>";
  html += "<p><span class='value'>" + String(readMQ135()) + "</span></p>";
  html += "<p>Raw ADC Value: <span class='value'>" + String(analogRead(mq135Pin)) + "</span></p>";
  html += "</body></html>";
  
  server.send(200, "text/html", html);
}

void handleData() {
  // Create a proper JSON object
  String json = "{";
  json += "\"sensor_value\":" + String(readMQ135()) + ",";
  json += "\"adc_value\":" + String(analogRead(mq135Pin));
  json += "}";
  
  // Set proper JSON headers
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", json);
}

float readMQ135() {
  // Read analog value (0-4095)
  int adcValue = analogRead(mq135Pin);
  
  // Convert to voltage (0-3.3V)
  float voltage = adcValue * (3.3 / 4095.0);
  
  // Basic conversion to PPM (this requires calibration for your specific sensor!)
  // You should implement proper calibration for your application
  float ppm = voltage * 100; // Example conversion, adjust this!
  
  return ppm;
}
