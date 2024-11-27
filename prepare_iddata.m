function [dati_ide, dati_val] = prepare_iddata(y, u, ts, train_ratio)
    % Funzione per creare gli oggetti iddata per identificazione e validazione
    % INPUT:
    %   y           - Segnale di uscita (vettore)
    %   u           - Segnale di ingresso (vettore)
    %   ts          - Tempo di campionamento
    %   train_ratio - Proporzione dei dati per l'identificazione (es. 0.7)
    % OUTPUT:
    %   dati_ide    - Oggetto iddata per identificazione
    %   dati_val    - Oggetto iddata per validazione

    % Determina l'indice di separazione
    N = length(y);
    idx_split = round(train_ratio * N);

    % Dati di identificazione
    y_ide = y(1:idx_split);
    u_ide = u(1:idx_split);

    % Dati di validazione
    y_val = y(idx_split+1:end);
    u_val = u(idx_split+1:end);

    % Creazione oggetti iddata
    dati_ide = iddata(y_ide, u_ide, ts);
    dati_val = iddata(y_val, u_val, ts);
end
