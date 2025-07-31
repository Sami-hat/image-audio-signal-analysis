% Audio Signal Analysis (Parts 1 & 2)

close all;

function filterAudio(fileNo)
    %%% IMPORTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    filepath = 'Data/Audio/audio_in_noise';
    [y, Fs] = audioread(filepath + fileNo + '.wav');

    N = length(y); % Total number of samples
    nyquist = Fs / 2; % Nyquist frequency
    
    %%% FFT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fft_result = fft(y);
    magnitude = abs(fft_result); 

    % x-axis
    frequencies = linspace(0, nyquist, floor(N/2));
    % y-axis
    positive_magnitude = magnitude(1:floor(length(magnitude)/2));
    
    %%% FILTERING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Threshold peaks above 10% of the max frequency
    threshold = max(positive_magnitude) * 0.1; 
    % Identify all peak-indicies above theshold
    [~, peak_indices] = findpeaks( ...
        positive_magnitude, ...
        'MinPeakHeight', ...
        threshold);

    % Get corresponding frequencies
    peak_frequencies = frequencies(peak_indices); 

    bandwidth = 20; % Bandwidth in Hz
    filtered_audio = y;

    for i = 1:length(peak_frequencies)
        % Define cutoff frequencies for notch filter
        low_cutoff = (peak_frequencies(i) - bandwidth / 2) / nyquist;
        high_cutoff = (peak_frequencies(i) + bandwidth / 2) / nyquist;
        
        % Create notch filter
        [b, a] = butter(2, [low_cutoff, high_cutoff], 'stop');
        
        % Apply notch filter
        filtered_audio = filter(b, a, filtered_audio);
    end

    %%% IFFT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    figure;
    subplot(2, 1, 1);
    plot((1:N) / Fs, y);
    title('Original Time Domain of Audio File' + fileNo);
    xlabel('Time (s)');
    ylabel('Magnitude');

    subplot(2, 1, 2);
    plot((1:N) / Fs, filtered_audio);
    title('Filtered Time Domain of Audio File' + fileNo);
    xlabel('Time (s)');
    ylabel('Magnitude');

    %%% EXPORTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Save the filtered audio to a new file
    % audiowrite( ...
    %     'Data/Audio/noise_removed' + fileNo + '.wav', ...
    %     filtered_audio, Fs);

    % Plotting 
    figure;
    subplot(2, 1, 1);
    plot(frequencies, positive_magnitude);
    title('FFT of Audio File ' + fileNo);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;

    % FFT of the filtered audio
    filtered_fft = fft(filtered_audio);
    filtered_magnitude = abs(filtered_fft(1:floor(length(filtered_fft)/2)));
    subplot(2, 1, 2);
    plot(frequencies, filtered_magnitude);
    title('Filtered FFT of Audio File ' + fileNo);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;

end

filterAudio("1"); % Run audio file 1
filterAudio("2"); % Run audio file 2
filterAudio("3"); % Run audio file 3


% Download plots
% exportgraphics(gcf,"Data/Audio/Filtered/fft_and_filtered"+ fileNo + ".png","Resolution",300);