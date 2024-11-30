
clc
clear
close all
rng('default');

set(0, 'defaultAxesFontSize', 12)
set(0, 'DefaultLineLineWidth', 2);
set(0, 'defaultAxesFontSize', 14)
set(0, 'defaultAxesTickLabelInterpreter','latex'); 
set(0, 'defaultlegendInterpreter','latex')

%% Multisine input design

fs = 1; % sampling frequency [Hz]
Ts = 1/fs; % sampling period [s]
nyquist_freq = fs/2; % Nyquist frequency (half of sampling frequency) [Hz]

bin = 0.001; % bin = fs/Nperiod = frequency resolution [Hz]
P = 3; % number of periods
Range = [-2 2]; % desired amplitude of the sinuoids

min_freq = 0; % min excited frequency [Hz]
max_freq = 0.5; % max excited frequency [Hz]

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


%% Plot the multisine in frequency domain 

freqs = (0:bin:fs-bin)'; % full frequency grid 
Ucheck = fft(u_ms(1:Nperiod)); % FFT of one multisine period

figure
stem(freqs, abs(Ucheck), 'r', 'LineWidth', 2);
ylim([0, max(abs(Ucheck))*1.1]);
grid on;
title('\textbf{Multisine spectrum}', 'interpreter', 'latex');
xlabel('Frequency [Hz]', 'interpreter', 'latex'); ylabel('Amplitude', 'interpreter', 'latex');

figure
stem(freqs_excited, abs(Ucheck(lines)), 'r', 'LineWidth', 2);
ylim([0, max(abs(Ucheck))*1.1]);
xlim([0, max(freqs_excited)]);
grid on;
title('\textbf{Multisine spectrum (zoom)}', 'interpreter', 'latex');
xlabel('Frequency [Hz]', 'interpreter', 'latex'); ylabel('Amplitude', 'interpreter', 'latex');



%% Transfer function G(z)
z = tf('z', Ts);
G0z = (z^-3 * (0.103 + 0.181*z^-1)) / (1 - 1.991*z^-1 +2.203*z^-2 - 1.841*z^-3 + 0.894*z^-4); 
G0z.Variable = 'z^-1';
G0z

puls_eval = 1e-2:1e-2:(fs*pi);
[mag, phase] = bode(G0z, puls_eval);
mod = squeeze(mag);
pha = squeeze(phase);

%% Transfer function H(z)
H0z = 1; % output-error system



 
%% Generate output

rng('default');
e = 0.5*randn(N, 1); % generate noise input vector
y_ms = lsim(G0z, u_ms, time) + H0z*e; % generate output data  

%% Pre-process data

% Remove initial condition to obtain a stationary process
Nperiods_remove = 1; % number of periods to remore
P = P - Nperiods_remove; % remaining periods
u_ms = u_ms(Nperiods_remove*Nperiod+1:end);
y_ms = y_ms(Nperiods_remove*Nperiod+1:end);
N = N - Nperiods_remove*Nperiod;
time = 0:Ts:(N*Ts)-Ts;


figure; 
h1 = subplot(211);
plot(time, u_ms ,'r');
ylim(Range*1.1); 
xlim([0, time(end)]); 
xlabel('Time [s]', 'interpreter', 'latex'); ylabel('Input $u(t)$', 'interpreter', 'latex');  grid on
title('\textbf{Multisine input}', 'interpreter', 'latex');
h2 = subplot(212);
hold all; 
plot(time, y_ms, 'b');
ylim(Range*1.1); 
xlim([0, time(end)]); 
xlabel('Time [s]', 'interpreter', 'latex'); ylabel('Output $y(t)$', 'interpreter', 'latex');  grid on
linkaxes([h1, h2]);


%% Nonparametric estimate

% reshape data as N x P
y_ms_P = reshape(y_ms, Nperiod, P);
u_ms_P = reshape(u_ms, Nperiod, P);
Ghatnp_P = zeros(Nperiod, P);  % nonparametric estimate of G with data from period pp
Y = zeros(Nperiod, P); % FFT of y data from period pp
U = zeros(Nperiod, P); % FFT of u data from period pp
for pp = 1 : 1 : P % spectral averaging
    Y(:, pp) = fft(y_ms_P(:, pp)); 
    U(:, pp) = fft(u_ms_P(:, pp)); 
end

Ghatnp = mean(Y, 2) ./ mean(U, 2);

modGhat_np = abs(Ghatnp) ;
phaGhat_np = ( rad2deg( angle( Ghatnp )  ));


%% Estimate parametric model with multisine input

data = iddata(y_ms, u_ms, Ts); % identification data
model = oe(data, [2, 4, 3]); % identify OE model
present(model) % show identified model

Ghatz = tf(model.B, model.F, Ts); % build Ghat(z)
Ghatz.Variable = 'z^-1';


% Compare with true G0(z)
[maghat, phasehat] = bode(Ghatz, puls_eval);
modhat = squeeze(maghat);
phahat = squeeze(phasehat);
%
figure
% subplot 211
semilogx(freqs*2*pi, db(modGhat_np), 'g*');
hold on
semilogx(puls_eval, db(modhat), 'b', 'linewidth', 2);
semilogx(puls_eval, db(mod), 'k--', 'linewidth', 2);
xlim([min(puls_eval), max(puls_eval)]);
ylim([-40, 30])
ylabel('Amplitude [dB]', 'interpreter', 'latex');
legend('$\hat{G}(e^{j\omega_k})$', '$\hat{G}(z,$ {\boldmath$\hat{\theta}$} $)$', '$G_0(z)$', 'fontsize', 16, 'interpreter', 'latex', 'location', 'best');
grid on;  
title('\textbf{Multisine input}', 'interpreter', 'latex');
xlabel('Frequency [rad/s]', 'interpreter', 'latex'); 

%
% subplot 212
% semilogx(puls_eval, phahat, 'b', 'linewidth', 2);
% hold on
% semilogx(puls_eval, pha, 'k--', 'linewidth', 2);
% xlim([min(puls_eval), max(puls_eval)]);
% ylim([-800, 0])
% xlabel('Frequency [rad/s]', 'interpreter', 'latex'); 
% ylabel('Phase [$$^\circ$$]', 'interpreter', 'latex');
% grid on;



