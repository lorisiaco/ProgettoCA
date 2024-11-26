media=mean(pw); %Uso il valore medio della PWM come punto di equilibrio
A=media*ones(2001, 1);   %Matrice di solo valore media da mettere nel simulatore
%A(end-199:end) = 0;         % Imposta gli ultimi 100 valori a 0

%Con una pw di 141.45 abbiamo l'angolo di 157.1, voglio delle u affinche ho
%+/- 157.1, tramite esperimenti scopro che la pw che mi fa avere 147.1 è
LimiteInf=128.755*ones(2001, 1);    %Ottengo    gradi di 147.1002
LimiteSup=174.75*ones(2001, 1);      %Ottengo gradi di 167.1004

%Creo entrata di controllo randomico, affiche abbia piu/meno 157.1 gradi
upper_bound = 174.75;
lower_bound = 128.755;
%block_size = 30;       % Dimensione del blocco
%total_length = 2001;   % Lunghezza del vettore
% Generazione del vettore
Urand = lower_bound + (upper_bound - lower_bound) * rand(2001, 1);
%random_vector = lower_bound + (upper_bound - lower_bound) * randi([0, 1], 2001, 1); %per avere non valori compresi

%Se voglio avere valori uguali per blocchi di tot lunghezza
% Numero di blocchi necessari
%num_blocks = ceil(total_length / block_size);

% Generazione di valori casuali per ciascun blocco
%block_values = lower_bound + (upper_bound - lower_bound) * rand(num_blocks, 1);

% Ripeti ciascun valore per il numero di valori nel blocco
%random_vector = repelem(block_values, block_size);

% Taglia il vettore per ottenere esattamente 2001 valori
%Urand30 = random_vector(1:total_length);

%---------------------------------------------------------------
%Procedo all'identificazione del processo con il Sytem Identification toolbox
%Prima procedo a ridurre il dataset affinchè abbia 70% per identificazione
%e 30% per validazione

U_ide = Urand(1:1400);  % I primi 1400 valori, circa il 70%
U_val = Urand(1401:end);  % I valori rimanenti

%disp(U_ide);

%Rifaccio anche per la Y 

Y_ide = y(1:1400);  % I primi 1400 valori, circa il 70%
Y_val = y(1401:end);  % I valori rimanenti 

%disp(Y_ide);

%Utilizzo il comando ident
%Facendo cosi ottengo un modello ARX A(z)y(t) = B(z)u(t) + e(t) avendo
%  A(z) = 1 - 3.305 z^-1 + 4.23 z^-2 - 2.507 z^-3 + 0.5832 z^-4           
%  B(z) = 0.0004185 z^-1 + 0.000543 z^-2 + 0.0009815 z^-3 + 7.904e-06 z^-4
%con Fit to estimation data del 98.89%

%-----------------------ECCITATAMENTO CON SINUSOIDE UPPER E LOWER--------------------------
% Calcolo ampiezza e offset
amplitude = (upper_bound - lower_bound) / 2; % Ampiezza
offset = (upper_bound + lower_bound) / 2;   % Offset

% Parametri della sinusoide
frequency = 1;   % Frequenza in Hz
duration = 100;    % Durata totale in secondi
sampling_interval = 0.05; % Passo temporale in secondi

% Asse del tempo
t = 0:sampling_interval:duration; % Campionamento a intervalli di 0.05 secondi

% Creazione della sinusoide
sinusoide = amplitude * sin(2 * pi * frequency * t) + offset;
s=sinusoide';

%Rifaccio come prima, identifico un modello dividendo i dataset(Ricorda di
%mettere in entrata al Simulink time,s se no rimane salvata la y di prima)

s_ide = s(1:1400);  % I primi 1400 valori, circa il 70%
s_val = s(1401:end);  % I valori rimanenti

%disp(s_ide);

%Rifaccio anche per la Y 

Ys_ide = y(1:1400);  % I primi 1400 valori, circa il 70%
Ys_val = y(1401:end);  % I valori rimanenti 

%disp(Ys_ide);

%Utilizzo il comando ident
%Facendo cosi ottengo un modello ARX A(z)y(t) = B(z)u(t) + e(t) avendo
% A(z) = 1 - 3.149 z^-1 + 4.076 z^-2 - 2.576 z^-3 + 0.6641 z^-4
% B(z) = 0.03734 z^-1 - 0.0535 z^-3 + 0.03169 z^-4  
%con Fit to estimation data del 99.42% ATTENZIONE MOLTO STRANOOOOO
%ATTENZIONEEE

%-----------------------ECCITATAMENTO CON PRBS-------------------------
prbs_full = idinput(2001, 'prbs', [0 1], [128.755 174.75]);
prbs = prbs_full(1:2001);

%Rifaccio come prima, identifico un modello dividendo i dataset(Ricorda di
%mettere in entrata al Simulink time,s se no rimane salvata la y di prima)

prbs_ide = prbs(1:1400);  % I primi 1400 valori, circa il 70%
prbs_val = prbs(1401:end);  % I valori rimanenti

%disp(prbs_ide);

%Rifaccio anche per la Y 

Yprbs_ide = y(1:1400);  % I primi 1400 valori, circa il 70%
Yprbs_val = y(1401:end);  % I valori rimanenti 

%disp(Yprbs_ide);

%Utilizzo il comando ident
%Facendo cosi ottengo un modello ARX A(z)y(t) = B(z)u(t) + e(t) avendo
%   A(z) = 1 - 2.862 z^-1 + 3.241 z^-2 - 1.733 z^-3 + 0.365 z^-4     
%   B(z) = 0.0009768 z^-1 + 0.0127 z^-2 + 0.01033 z^-3 - 0.01275 z^-4
%con Fit to estimation data del 97.54%




%-----------------------------------------------------------------------------
%Trovato il processo procedo con il controllo
% Coefficienti del modello ARX
%A = [1, -1.686, 0.6294, 0.1527, -0.07386];  % Coefficienti di A(z)
%B = [0.009574, -0.0003455, 0.004443, 0.007336]; % Coefficienti di B(z)


