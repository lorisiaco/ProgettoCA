function u_ms = creaMultiSin(min,max,Ts,min_freq,max_freq)

%% Multisine input design
rng('default');

set(0, 'defaultAxesFontSize', 12)
set(0, 'DefaultLineLineWidth', 2);
set(0, 'defaultAxesFontSize', 14)
set(0, 'defaultAxesTickLabelInterpreter','latex'); 
set(0, 'defaultlegendInterpreter','latex')

fs = 1/Ts; % sampling frequency [Hz]
nyquist_freq = fs/2; % Nyquist frequency (half of sampling frequency) [Hz]

bin = 0.001; % bin = fs/Nperiod = frequency resolution [Hz]
P = 3; % number of periods
Range = [min max]; % desired amplitude of the sinuoids


Band = [min_freq max_freq]/nyquist_freq; % normalize excited freq. band w.r.t. the Nyquist freq.

linesMin = ceil(min_freq/bin) + 2; % lowest bin multiple, do not excite constant frequency
linesMax = floor(max_freq/bin); % highest bin multiple
lines = (linesMin:linesMax)'; % bin counts
n_sines = size(lines, 1); % number of sines
n_trials = 10; % number of random phases to minimize signal peaks
grid_spacing = 1; % spacing between consecutive sines
sinedata = [n_sines, n_trials, grid_spacing];

Nperiod = fs/bin; % data points per period

[u_ms, pulsations_excited] = idinput([Nperiod 1 P], 'sine', Band, Range, sinedata); % generate ms signal
N = size(u_ms, 1); % number of data
freqs_excited = (pulsations_excited * fs/2/pi)'; % convert normalized pulsation to physical frequencies
time = (0:Ts:(N*Ts)-Ts)';


% %% Plot the multisine in frequency domain 
% 
% freqs = (0:bin:fs-bin)'; % full frequency grid 
% Ucheck = fft(u_ms(1:Nperiod)); % FFT of one multisine period
% 
% figure
% stem(freqs, abs(Ucheck), 'r', 'LineWidth', 2);
% ylim([0, max(abs(Ucheck))*1.1]);
% grid on;
% title('\textbf{Multisine spectrum}', 'interpreter', 'latex');
% xlabel('Frequency [Hz]', 'interpreter', 'latex'); ylabel('Amplitude', 'interpreter', 'latex');
% 
% figure
% stem(freqs_excited, abs(Ucheck(lines)), 'r', 'LineWidth', 2);
% ylim([0, max(abs(Ucheck))*1.1]);
% xlim([0, max(freqs_excited)]);
% grid on;
% title('\textbf{Multisine spectrum (zoom)}', 'interpreter', 'latex');
% xlabel('Frequency [Hz]', 'interpreter', 'latex'); ylabel('Amplitude', 'interpreter', 'latex');
