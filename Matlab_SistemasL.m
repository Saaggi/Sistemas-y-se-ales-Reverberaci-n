% ---- Lectura y graficación del audio ----
[audio, fs] = audioread('Mim9.wav');
audio = audio(:, 1); % Si el audio es estéreo, usamos un solo canal
t_audio = (0:length(audio)-1) / fs; % Eje de tiempo para el audio

% Graficar el audio de entrada
figure;
plot(t_audio, audio, 'b');
title('Señal de Entrada: Audio Original');
xlabel('Tiempo [s]');
ylabel('Amplitud');
grid on;

% ---- Recorte del audio ----
% Definir los tiempos de corte (en segundos)
start_time = 0.5; % Tiempo inicial
end_time = 3.7;   % Tiempo final

% Convertir los tiempos de corte a índices de muestra
start_sample = round(start_time * fs);
end_sample = min(round(end_time * fs), length(audio)); % Asegurar que no exceda el tamaño del audio

% Recortar la señal de audio
audio_cortado = audio(start_sample:end_sample);
t_audio_cortado = (0:length(audio_cortado)-1) / fs; % Ajuste para que comience en t = 0

% Graficar la señal recortada
figure;
plot(t_audio_cortado, audio_cortado, 'r');
title('Señal de Audio Recortada (Ajustada para comenzar en t=0)');
xlabel('Tiempo [s]');
ylabel('Amplitud');
grid on;

% Guardar la señal recortada como un nuevo archivo (opcional)
audiowrite('Mim9recortado_delay.wav', audio_cortado, fs);

% ---- Respuesta al impulso h(t) ----
impulse_gap = round(0.8 * fs); % Espaciado entre impulsos (ajustado para estar más cerca)
num_impulses = 8; % Número de impulsos
h = zeros(1, num_impulses * impulse_gap); % Inicializamos h(t)
for i = 1:num_impulses
    h((i-1)*impulse_gap + 1) = 0.5^(i-1); % Amplitud decreciente a la mitad por impulso
end
t_h = (0:length(h)-1) / fs; % Eje de tiempo para h(t)

% ---- Implementación de la convolución ----
len_audio = length(audio_cortado); % Usamos la señal recortada
len_h = length(h);
len_conv = len_audio + len_h - 1;
output = zeros(len_conv, 1); % Inicializamos la señal de salida

% Convolución manual
for n = 1:len_conv
    for k = 1:len_h
        if (n - k + 1 > 0) && (n - k + 1 <= len_audio)
            output(n) = output(n) + h(k) * audio_cortado(n - k + 1);
        end
    end
end

% Normalizar y guardar el audio procesado
output = output / max(abs(output)); % Normalización
audiowrite('Mim9_delay.wav', output, fs); % Guardar el audio procesado como un nuevo archivo

% Eje de tiempo para la salida
t_output = (0:length(output)-1) / fs;

% ---- Graficar señales ----
figure;

% Graficar respuesta al impulso
subplot(3, 1, 1);
stem(t_h, h, 'r', 'Marker', 'none');
title('Respuesta al Impulso h(t): Simulación de Reverberación');
xlabel('Tiempo [s]');
ylabel('Amplitud');
grid on;

% Graficar señal recortada (entrada de la convolución)
subplot(3, 1, 2);
plot(t_audio_cortado, audio_cortado, 'b');
title('Señal de Entrada Recortada para la Convolución');
xlabel('Tiempo [s]');
ylabel('Amplitud');
grid on;

% Graficar señal de salida
subplot(3, 1, 3);
plot(t_output, output, 'g');
title('Señal de Salida: Audio Reverberado');
xlabel('Tiempo [s]');
ylabel('Amplitud');
grid on;

% Reproducir el audio procesado
sound(output, fs);
