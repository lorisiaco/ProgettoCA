function plot_signals(t, signal1, signal2, title1, title2)
    figure;

    % Primo segnale
    subplot(2, 1, 1);
    plot(t, signal1, 'b');
    xlabel('Time (s)');
    ylabel('gradi');
    title(title1);
    grid on;

    % Secondo segnale
    subplot(2, 1, 2);
    plot(t, signal2, 'r');
    xlabel('Time (s)');
    ylabel('pwm (microsecondi)');
    title(title2);
    grid on;
end
