function varargout = DaphniaGUI(varargin)
% DAPHNIAGUI MATLAB code for DaphniaGUI.fig
%      DAPHNIAGUI, by itself, creates a new DAPHNIAGUI or raises the existing
%      singleton*.
%
%      H = DAPHNIAGUI returns the handle to a new DAPHNIAGUI or the handle to
%      the existing singleton*.
%
%      DAPHNIAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DAPHNIAGUI.M with the given input arguments.
%
%      DAPHNIAGUI('Property','Value',...) creates a new DAPHNIAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DaphniaGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DaphniaGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DaphniaGUI

% Last Modified by GUIDE v2.5 10-Mar-2020 12:39:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DaphniaGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DaphniaGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before DaphniaGUI is made visible.
function DaphniaGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DaphniaGUI (see VARARGIN)

% Choose default command line output for DaphniaGUI

%% Set initial parameters
handles = setfield(handles, 'gain', 1);
handles = setfield(handles, 'exposure', 5);
handles = setfield(handles, 'framerate', 25);
handles = setfield(handles, 'pixelclock', 35);

% handles = setfield(handles, 'cohort_num', []);
% handles = setfield(handles, 'vid_num', []);
% handles = setfield(handles, 'drug_dose', []);

handles = setfield(handles, 'metadata', 30);

% Set stimulus timing
handles = setfield(handles, 'light_stim_on', 10);
handles = setfield(handles, 'light_stim_off', 40);
handles = setfield(handles, 'vib_stim_on', 10);
handles = setfield(handles, 'vib_stim_off', 20);

% Set stimulus magnitude & arduino ports
handles = setfield(handles, 'light_level', 3);
handles = setfield(handles, 'vib_level', 1);

handles = setfield(handles,'top_light', 'D2');
handles = setfield(handles,'bottom_light', 'D3');
handles = setfield(handles,'left_light', 'D4');
handles = setfield(handles,'right_light', 'D5');

handles = setfield(handles,'right_vib1', 'D8');
handles = setfield(handles,'right_vib2', 'D9');
handles = setfield(handles,'left_vib1', 'D10');
handles = setfield(handles,'left_vib2', 'D11');

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DaphniaGUI wait for user response (see UIRESUME)
% uiwait(handles.DaphniaGui);
end

% --- Outputs from this function are returned to the command line.
function varargout = DaphniaGUI_OutputFcn(~, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in init_cam.
function init_cam_Callback(hObject, eventdata, handles)
% hObject    handle to init_cam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    % Initiate Camera

    % Load .NET assembly
    NET.addAssembly('E:\OneDrive - Harvard University\Research_Kirschner group\MATLAB_script\Daphnia\DaphniaGUI\uc480DotNet.dll');
    import uc480DotNet.*
    % May need to change specific location of library
    asm = System.AppDomain.CurrentDomain.GetAssemblies;
    if ~any(arrayfun(@(n) strncmpi(char(asm.Get(n-1).FullName), ...
      'uc480DotNet', length('uc480DotNet')), 1:asm.Length))
     NET.addAssembly(...
      'C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\uc480DotNet.dll');
    end
           
    % Create camera object
    cam = uc480.Camera;

    % Initialize camera, setting window handle for display
    % Change the first argument from 0 to camera ID to initialize a specific
    % camera, otherwise first camera found will be initialized
    %cam.Init(0, h.Handle);
    cam.Init(0);

    % Ensure Direct3D mode is set
    %cam.Display.Mode.Set(uc480.Defines.DisplayMode.Direct3D);
    cam.Display.Mode.Set(uc480.Defines.DisplayMode.DiB);

    % Set to mono
    err = cam.PixelFormat.Set(uc480.Defines.ColorMode.Mono8); % Mono8 - p205

    % Set up camera for copying image to Matlab memory for processing
    [err, ID] = cam.Memory.Allocate(true);
    [err, Width, Height] = cam.Memory.GetSize(ID);
    cam.DirectRenderer.SetStealFormat(uc480.Defines.ColorMode.Mono8);
    
    % Start live capture
    status = 'Camera is connected';
    set(handles.status_display,'String',status);
    set(handles.status_display,'ForegroundColor',[1, 0, 0]);
    set(handles.init_cam, 'Enable','off');
    set(handles.exit_camera, 'Enable','on');   
    % Update handles structure
    handles.cam = cam;
    handles.camera.ID = ID;
    handles.camera.err = err;
    handles.camera.width = Width;
    handles.camera.height = Height;
    guidata(hObject, handles);
end

% function DGui = init_camera(DGui)
%     % Initiate Camera
% 
%     % Load .NET assembly
%     NET.addAssembly('C:\MATLAB\ControlGUI\DaphniaGUI\uc480DotNet.dll');
%     import uc480DotNet.*
%     % May need to change specific location of library
%     asm = System.AppDomain.CurrentDomain.GetAssemblies;
%     if ~any(arrayfun(@(n) strncmpi(char(asm.Get(n-1).FullName), ...
%       'uc480DotNet', length('uc480DotNet')), 1:asm.Length))
%      NET.addAssembly(...
%       'C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\uc480DotNet.dll');
%     end
%     
%     % Create window to display image
%     NET.addAssembly('System.Windows.Forms');
%     if ~exist('h', 'var')
%          h = System.Windows.Forms.Form;
%          h.Show;
%     end
%     
%     % Create camera object
%     cam = uc480.Camera;
% 
%     % Initialize camera, setting window handle for display
%     % Change the first argument from 0 to camera ID to initialize a specific
%     % camera, otherwise first camera found will be initialized
%     cam.Init(0, h.Handle);
% 
%     % Ensure Direct3D mode is set
%     cam.Display.Mode.Set(uc480.Defines.DisplayMode.Direct3D);
% 
%     % Set to mono
%     err = cam.PixelFormat.Set(uc480.Defines.ColorMode.Mono8); % Mono8 - p205
% 
%     % Set up camera for copying image to Matlab memory for processing
%     [err, ID] = cam.Memory.Allocate(true);
%     [err, Width, Height] = cam.Memory.GetSize(ID);
%     cam.DirectRenderer.SetStealFormat(uc480.Defines.ColorMode.Mono8); 
% 
%     % Set up matlab figure for processed image
%     %clf
%     figure(2); hImg = imagesc;
%     
%     hStp = uicontrol('Style', 'ToggleButton', 'String', 'Stop', ...
%      'ForegroundColor', 'r', 'FontWeight', 'Bold', 'FontSize', 20);
%     hStp.Position(3:4) = [100 50];
%         
%      
%     % Start live capture
%     cam.Acquisition.Capture;
% 
%     status = 'Capturing images';
%     set(handles.status_display,'String',status);
%     set(handles.status_display,'ForegroundColor',[1, 0, 0]);
%     while ~hStp.Value || strcmp(char(err), char(uc480.Defines.Status))
%          % Copy image from graphics card to RAM (wait for completion)
%          cam.DirectRenderer.StealNextFrame(uc480.Defines.DeviceParameter.Wait);
% 
%          % Copy image from RAM to Matlab array
%          [err, I] = cam.Memory.CopyToArray(ID);
% 
%          I = reshape(uint8(I), Width, Height,[]).';
% 
%         %  I = permute(I, [2, 1, 3]);
%         %  I = I(:,:,1);
%          % Calculate marginals
%          Ix = sum(uint64(I));
%          Iy = sum(uint64(I), 2);
% 
%          % Plot data
%          hImg = imshow(I);
%          axis(hImg.Parent, 'image');
%          axis(hImg.Parent, 'tight');
% 
%     end
%     set(DGui.init_cam, 'Enable','off');
%     set(DGui.exit_cam, 'Enable','on');
% end
% 

% --- Executes on button press in exit_camera.
function exit_camera_Callback(hObject, eventdata, handles)
% hObject    handle to exit_camera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = exit_camera(handles);

    % Update handles structure
    guidata(handles.output, handles);
end

function DGui = exit_camera(DGui)
    % Disengage Camera
    cam = DGui.cam;
    ID = DGui.camera.ID;
    
    % Stop capture
    cam.Acquisition.Stop;
    % Free image memory
    cam.Memory.Free(ID);

    status = 'Exit Camera';
    set(DGui.status_display,'String',status);
    set(DGui.status_display,'ForegroundColor',[1, 0, 0]);
    set(DGui.exit_camera, 'Enable','off');
    set(DGui.init_cam, 'Enable','on');
    % Close camera - ALWAYS make sure the camera is closed before attempting to
    % initialize again!!!
    cam.Exit;
end


% --- Executes during object deletion, before destroying properties.
function DaphniaGui_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to DaphniaGui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


% --- Executes when user attempts to close DaphniaGui.
function DaphniaGui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to DaphniaGui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
    delete(hObject);
end


% --- Executes on button press in live_cam.
function live_cam_Callback(hObject, eventdata, handles)
% hObject    handle to live_cam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    cam = handles.cam;
    ID = handles.camera.ID;
    err = handles.camera.err;
    Width = handles.camera.width;
    Height = handles.camera.height;

        
    status = 'Capturing images';
    set(handles.status_display,'String',status);
    set(handles.status_display,'ForegroundColor',[1, 0, 0]);
    set(handles.live_cam, 'Enable','off');
    
    % Start live capture
    cam.Acquisition.Capture;
     
    handles = video_settings(handles);
    
    while ~get(handles.stoplive,'Value') % && ~strcmp(err, uc480.Defines.Status.NO_SUCCESS)
         pause(0.01);
         cam.DirectRenderer.StealNextFrame(uc480.Defines.DeviceParameter.Wait);
         [err, I] = cam.Memory.CopyToArray(ID);
        
         I = reshape(uint8(I), Width, Height,[]).';
         handles.Image = I;
         axes(handles.axes1);
         imshow(I);
    end
end

function DGui = video_settings(DGui)

    cam = DGui.cam;
    
%     if ischar(str2double(get(DGui.exposure,'string')))
%         DGui.exposure = str2double(get(DGui.exposure,'string'));
%     elseif isa(DGui.exposure,'double')
%         DGui.exposure = DGui.exposure;
%     end
%             
    exposure = DGui.exposure;        
    cam.Timing.Exposure.Set(exposure);
    fps = DGui.framerate; 
    cam.Timing.Framerate.Set(fps);
    pixelclock = DGui.pixelclock;
    cam.Timing.PixelClock.Set(pixelclock);
    cam.Video.SetQuality(95);
end

function DGui = video_filename(DGui)
    
    % File name
    strNewDir = get(DGui.save_directory,'string');
    if ~exist(strNewDir)
        mkdir(strNewDir);
    end
    
    filename = get(DGui.filename,'string');
    cohort_num = get(DGui.cohort_number,'string');
    vid_num = get(DGui.vid_num,'String');
    date = datestr(today('datetime'));
    
    expcond = DGui.expcond;
    
    if get(DGui.filename_control,'value') == 1
        filename = [strNewDir filename '_' cohort_num '_control_' date];
    
    elseif get(DGui.filename_drug,'value') == 1
        filename = [strNewDir filename '_' cohort_num '_drug_' date];
    
    elseif ischar(get(DGui.filename_drugname,'string')) && ...
            ischar(get(DGui.filename_drugdose,'string')) && ~ischar(expcond)
        
        drug = get(DGui.filename_drugname,'string');
        dose = get(DGui.filename_drugdose,'string');
        filename = [strNewDir filename '_' cohort_num '_' drug '_' dose '_' date];
    
    elseif ischar(expcond) && ~ischar(get(DGui.filename_drugname,'string')) ...
        && ~ischar(get(DGui.filename_drugdose,'string'))
        
        filename = [strNewDir filename '_' cohort_num '_' expcond '_' date];
        
    elseif ischar(expcond) && ischar(get(DGui.filename_drugname,'string')) ...
        && ischar(get(DGui.filename_drugdose,'string'))
        
        drug = get(DGui.filename_drugname,'string');
        dose = get(DGui.filename_drugdose,'string');
        filename = [strNewDir filename '_' cohort_num '_' drug ...
            '_' dose '_' expcond '_' date];
        
    else
        filename = [strNewDir filename '_' cohort_num '_' date];
    end
    
    new_filename = [filename '_' num2str(vid_num) '.avi'];
    
    
    DGui.new_filename = new_filename;
end

function save_directory_Callback(hObject, eventdata, handles)
% hObject    handle to save_directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_directory as text
%        str2double(get(hObject,'String')) returns contents of save_directory as a double
end

% --- Executes during object creation, after setting all properties.
function save_directory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in save_directory_button.
function save_directory_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_directory_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    directory_name = uigetdir('E:\Behavior\');
    set(handles.save_directory,'string',[directory_name,'\']);
end


% --- Executes on button press in VideoRecording.
function VideoRecording_Callback(hObject, eventdata, handles)
% hObject    handle to VideoRecording (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
    status = 'Video recording start';
    set(handles.status_display,'String',status);
    set(handles.status_display,'ForegroundColor',[1, 0, 0]);

    handles = video_settings(handles);
    handles = video_filename(handles); 
     
    cam = handles.cam;
    ID = handles.camera.ID;   
    Width = handles.camera.width;
    Height = handles.camera.height;
    
    light = get(handles.light_stim,'value');
    vibration = get(handles.vib_stim,'value');
    light_vib = get(handles.light_vib_stim,'value');
    
    record_time = handles.record_time;
    filename = handles.new_filename;    
    
    if exist(filename)
        status = 'Same name file is exist';
        set(handles.status_display,'String',status);
        set(handles.status_display,'ForegroundColor',[1, 0, 0]);
        
    else
        cam.PixelFormat.Set(uc480.Defines.ColorMode.Mono8);
        cam.IO.Flash.SetAutoFreerunEnable(true); 
        cam.Acquisition.Capture;
        cam.Video.Start(filename);
        
        timestamp = tic;
        while toc(timestamp) <= record_time

            cam.DirectRenderer.StealNextFrame(uc480.Defines.DeviceParameter.Wait);
             [err, I] = cam.Memory.CopyToArray(ID);

             I = reshape(uint8(I), Width, Height,[]).';
             % handles.Image = I;
             axes(handles.axes1);
             imshow(I);            
        end

        cam.Video.Stop();
        cam.Acquisition.Stop();

        handles = record_save(handles);
    end
    
    guidata(hObject,handles);
end

function DGui = record_save(DGui)
     %Data.record_time = DGui.record_time;
     Data.exposure = DGui.exposure;
     Data.metadata = DGui.metadata;
     
     save([DGui.new_filename(1:end-4) '.mat'],...
     'Data'); 

    % Increment counter
    vid_num = str2double(get(DGui.vid_num,'string')) + 1;
    % DGui.vid_num = vid_num;
    set(DGui.vid_num, 'String',vid_num);
    status = 'Video recording finish';
    set(DGui.status_display,'String',status);
    set(DGui.status_display,'ForegroundColor',[1, 0, 0]);
    guidata(DGui.output, DGui);
end


% --- Executes on button press in stoplive.
function stoplive_Callback(hObject, eventdata, handles)
% hObject    handle to stoplive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    status = 'Live imaging is stopped';
    set(handles.status_display,'String',status);
    set(handles.status_display,'ForegroundColor',[1, 0, 0]);
    set(handles.live_cam,'Enable','on');
    
% Hint: get(hObject,'Value') returns toggle state of stoplive
end



function gain_Callback(hObject, eventdata, handles)
% hObject    handle to gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gain as text
%        str2double(get(hObject,'String')) returns contents of gain as a double
    


    handles.gain = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function exposure_Callback(hObject, eventdata, handles)
% hObject    handle to exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exposure as text
%        str2double(get(hObject,'String')) returns contents of exposure as a double

    cam = handles.cam;
    handles.exposure = str2double(get(hObject,'String'));
    cam.Timing.Exposure.Set(handles.exposure);
    
    guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function exposure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function fps_Callback(hObject, eventdata, handles)
% hObject    handle to fps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fps as text
%        str2double(get(hObject,'String')) returns contents of fps as a double
    
    cam = handles.cam;
    handles.framerate = str2double(get(hObject,'String'));
    cam.Timing.Framerate.Set(handles.framerate);
    %handles.exposure = exposure;
    
    % Update handles structure
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function fps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function record_time_Callback(hObject, eventdata, handles)
% hObject    handle to record_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of record_time as text
%        str2double(get(hObject,'String')) returns contents of record_time as a double
    handles.record_time = str2double(get(hObject,'String'));

    % Update handles structure
    guidata(handles.output, handles);
end

% --- Executes during object creation, after setting all properties.
function record_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to record_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in init_controller.
function init_controller_Callback(hObject, eventdata, handles)
% hObject    handle to init_controller (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    ard = arduino('COM4', 'Mega2560');
    status = 'Arduino is connected';
    set(handles.status_display,'String',status);
    %set(handles.init_controller,'Enable','off');
    handles.ard = ard;
    guidata(handles.output, handles);
end


function cohort_number_Callback(hObject, eventdata, handles)
% hObject    handle to cohort_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cohort_number as text
%        str2double(get(hObject,'String')) returns contents of cohort_number as a double
    handles.cohort_num = str2double(get(hObject,'String'));
    guidata(handles.output, handles);
end

% --- Executes during object creation, after setting all properties.
function cohort_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cohort_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in light_stim.
function light_stim_Callback(hObject, eventdata, handles)
% hObject    handle to light_stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of light_stim
    handles.record_light_stim = get(hObject,'Value');
end

% --- Executes on button press in vib_stim.
function vib_stim_Callback(hObject, eventdata, handles)
% hObject    handle to vib_stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vib_stim
    handles.record_vib_stim = get(hObject,'Value');
end

% --- Executes on button press in light_vib_stim.
function light_vib_stim_Callback(hObject, eventdata, handles)
% hObject    handle to light_vib_stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of light_vib_stim
    handles.record_light_vib_stim = get(hObject,'Value');
end


function light_stim_on_Callback(hObject, eventdata, handles)
% hObject    handle to light_stim_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of light_stim_on as text
%        str2double(get(hObject,'String')) returns contents of light_stim_on as a double
    handles.light_stim_on = str2double(get(hObject,'String'));

    % Update handles structure
    guidata(handles.output, handles);
end

% --- Executes during object creation, after setting all properties.
function light_stim_on_CreateFcn(hObject, eventdata, handles)
% hObject    handle to light_stim_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function light_stim_off_Callback(hObject, eventdata, handles)
% hObject    handle to light_stim_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of light_stim_off as text
%        str2double(get(hObject,'String')) returns contents of light_stim_off as a double
    handles.light_stim_off = str2double(get(hObject,'String'));

    % Update handles structure
    guidata(handles.output, handles);
end

% --- Executes during object creation, after setting all properties.
function light_stim_off_CreateFcn(hObject, eventdata, handles)
% hObject    handle to light_stim_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function vib_stim_on_Callback(hObject, eventdata, handles)
% hObject    handle to vib_stim_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vib_stim_on as text
%        str2double(get(hObject,'String')) returns contents of vib_stim_on as a double
    handles.vib_stim_on = str2double(get(hObject,'String'));

    % Update handles structure
    guidata(handles.output, handles);
end

% --- Executes during object creation, after setting all properties.
function vib_stim_on_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vib_stim_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function vib_stim_off_Callback(hObject, eventdata, handles)
% hObject    handle to vib_stim_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vib_stim_off as text
%        str2double(get(hObject,'String')) returns contents of vib_stim_off as a double
    handles.vib_stim_off = str2double(get(hObject,'String'));

    % Update handles structure
    guidata(handles.output, handles);
end

% --- Executes during object creation, after setting all properties.
function vib_stim_off_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vib_stim_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end





% --- Executes on button press in count.
function count_Callback(hObject, eventdata, handles)
% hObject    handle to count (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of count
    handles.record_count = get(hObject,'Value');
    guidata(hObject, handles);
end



function light_level_Callback(hObject, eventdata, handles)
% hObject    handle to light_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of light_level as text
%        str2double(get(hObject,'String')) returns contents of light_level as a double
    light_level = str2double(get(hObject,'String'));
    if light_level < 1 || light_level > 3
        status = 'Error: Put right light level between 1 to 3';
        set(handles.status_display,'String',status);
        set(handles.status_display,'ForegroundColor',[1, 0, 0]);
    end
    handles.light_level = light_level;
    guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function light_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to light_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in light_top.
function light_top_Callback(hObject, eventdata, handles)
% hObject    handle to light_top (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of light_top
    handles.light_cond_top = get(hObject,'Value');
    %light_level = str2double(get(handles.light_level,'String'));
    light_level = handles.light_level;
    ard = handles.ard;
    port = handles.top_light;
    
    if ~exist('ard','var')
        status = 'Please connect Arduino';
        set(handles.status_display,'String',status);
        
    end
    
    if handles.light_cond_top == 1
       switch light_level
           case 1
               volt = 1;
           case 2
               volt = 3;
           case 3
               volt = 5;
       end
       writePWMVoltage(ard, port,volt);
    end
    
    if handles.light_cond_top == 0
       
       writePWMVoltage(ard, port, 0);
    end
    guidata(hObject, handles);
end


% --- Executes on button press in light_bottom.
function light_bottom_Callback(hObject, eventdata, handles)
% hObject    handle to light_bottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of light_bottom
    handles.light_cond_bottom = get(hObject,'Value');
    light_level = str2double(get(handles.light_level,'string'));
    ard = handles.ard;
    port = handles.bottom_light;
    
    if ~exist('ard','var')
        status = 'Please connect Arduino';
        set(handles.status_display,'String',status);
        
    end
    
    if handles.light_cond_bottom == 1
       switch light_level
           case 1
               volt = 1;
           case 2
               volt = 3;
           case 3
               volt = 5;
       end
       writePWMVoltage(ard, port,volt);
    end
    
    if handles.light_cond_bottom == 0
       
       writePWMVoltage(ard, port, 0);
    end
    guidata(hObject, handles);
end

% --- Executes on button press in light_right.
function light_right_Callback(hObject, eventdata, handles)
% hObject    handle to light_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of light_right
    handles.light_cond_right = get(hObject,'Value');
    light_level = handles.light_level;
    ard = handles.ard;
    port = handles.right_light;
    
    if ~exist('ard','var')
        status = 'Please connect Arduino';
        set(handles.status_display,'String',status);
        
    end
    
    if handles.light_cond_right == 1
       switch light_level
           case 1
               volt = 1;
           case 2
               volt = 3;
           case 3
               volt = 5;
       end
       writePWMVoltage(ard, port,volt);
    end
    
    if handles.light_cond_right == 0
       
       writePWMVoltage(ard, port, 0);
    end
    guidata(hObject, handles);
end

% --- Executes on button press in light_left.
function light_left_Callback(hObject, eventdata, handles)
% hObject    handle to light_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of light_left
    handles.light_cond_left = get(hObject,'Value');
    light_level = handles.light_level;
    ard = handles.ard;
    port = handles.left_light;
    
    if ~exist('ard','var')
        status = 'Please connect Arduino';
        set(handles.status_display,'String',status);
        
    end
    
    if handles.light_cond_left == 1
       switch light_level
           case 1
               volt = 1;
           case 2
               volt = 3;
           case 3
               volt = 5;
       end
       writePWMVoltage(ard, port,volt);
    end
    
    if handles.light_cond_left == 0
       
       writePWMVoltage(ard, port, 0);
    end
    guidata(hObject, handles);
end

% --- Executes on button press in record_count.
function record_count_Callback(hObject, eventdata, handles)
% hObject    handle to record_count (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles.expcond = 'Count';
    
    status = 'Counting Mode Start';
    set(handles.status_display,'String',status);
    set(handles.status_display,'ForegroundColor',[1, 0, 0]);
    
    handles = video_settings(handles);
    handles = video_filename(handles); 
    
    cam = handles.cam;
    ID = handles.camera.ID;   
    Width = handles.camera.width;
    Height = handles.camera.height;
         
    record_time = 20;
    filename = handles.new_filename;    
    
    %Stim. Parameters
    ard = handles.ard;
    port1 = handles.top_light;
    port2 = handles.bottom_light;
    port3 = handles.left_light;
    port4 = handles.right_light;
    volt = 5;
    
    light_stim_on = handles.light_stim_on;
    light_stim_off = handles.light_stim_off;
    light_level = handles.light_level;
    
    
    
    if exist(filename)
        status = 'Same name file is exist';
        set(handles.status_display,'String',status);
        set(handles.status_display,'ForegroundColor',[1, 0, 0]);
        
    else
        cam.PixelFormat.Set(uc480.Defines.ColorMode.Mono8);
        cam.IO.Flash.SetAutoFreerunEnable(true); 
        cam.Acquisition.Capture;
        cam.Video.Start(filename);
        
        timestamp = tic;
        while toc(timestamp) <= 20
            
             cam.DirectRenderer.StealNextFrame(uc480.Defines.DeviceParameter.Wait);
             [err, I] = cam.Memory.CopyToArray(ID);

             I = reshape(uint8(I), Width, Height,[]).';
             % handles.Image = I;
             axes(handles.axes1);
             imshow(I);            
             
             if (toc(timestamp) >= light_stim_on && toc(timestamp) <= light_stim_off)
                 writePWMVoltage(ard, port1,volt);
                 writePWMVoltage(ard, port2,volt);
                 writePWMVoltage(ard, port3,volt);
                 writePWMVoltage(ard, port4,volt);
             
             elseif (toc(timestamp)> light_stim_off)
                 writePWMVoltage(ard, port1, 0);
                 writePWMVoltage(ard, port2, 0);
                 writePWMVoltage(ard, port3, 0);
                 writePWMVoltage(ard, port4, 0);
             end
             
        end

        cam.Video.Stop();
        cam.Acquisition.Stop();

        handles = record_save(handles);
    end
    
    guidata(hObject,handles);
end

% --- Executes on button press in record_light.
function record_light_Callback(hObject, eventdata, handles)
% hObject    handle to record_light (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    handles.expcond = 'Light';

    status = 'Light Mode Start';
    set(handles.status_display,'String',status);
    set(handles.status_display,'ForegroundColor',[1, 0, 0]);
    
    handles = video_settings(handles);
    handles = video_filename(handles); 
    
    cam = handles.cam;
    ID = handles.camera.ID;   
    Width = handles.camera.width;
    Height = handles.camera.height;
    
    
     
    record_time = handles.record_time;
    filename = handles.new_filename;    
    
    %Stim. Parameters
    ard = handles.ard;
    port = handles.top_light;
    
    light_stim_on = handles.light_stim_on;
    light_stim_off = handles.light_stim_off;
    light_level = handles.light_level;
    
    switch light_level
       case 1
           volt = 1;
       case 2
           volt = 3;
       case 3
           volt = 5;
    end
    
    if exist(filename)
        status = 'Same name file is exist';
        set(handles.status_display,'String',status);
        set(handles.status_display,'ForegroundColor',[1, 0, 0]);
        
    else
        cam.PixelFormat.Set(uc480.Defines.ColorMode.Mono8);
        cam.IO.Flash.SetAutoFreerunEnable(true); 
        cam.Acquisition.Capture;
        cam.Video.Start(filename);
        
        timestamp = tic;
        while toc(timestamp) <= 60
            
             cam.DirectRenderer.StealNextFrame(uc480.Defines.DeviceParameter.Wait);
             [err, I] = cam.Memory.CopyToArray(ID);

             I = reshape(uint8(I), Width, Height,[]).';
             % handles.Image = I;
             axes(handles.axes1);
             imshow(I);            
             
             if (toc(timestamp) >= light_stim_on && toc(timestamp) <= light_stim_off)
                 writePWMVoltage(ard, port,volt);
                 
             elseif (toc(timestamp)> light_stim_off)
                 writePWMVoltage(ard, port, 0);
             end
             
        end

        cam.Video.Stop();
        cam.Acquisition.Stop();

        handles = record_save(handles);
    end
    
    guidata(hObject,handles);
end

% --- Executes on button press in record_vib.
function record_vib_Callback(hObject, eventdata, handles)
% hObject    handle to record_vib (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    handles.expcond = 'Vib';

    status = 'Vibration Mode Start';
    set(handles.status_display,'String',status);
    set(handles.status_display,'ForegroundColor',[1, 0, 0]);
    
    handles = video_settings(handles);
    handles = video_filename(handles); 
    
    cam = handles.cam;
    ID = handles.camera.ID;   
    Width = handles.camera.width;
    Height = handles.camera.height;
     
    record_time = handles.record_time;
    filename = handles.new_filename;    

    %Stim. Parameters
    ard = handles.ard;
    port1 = handles.right_vib1;
    port2 = handles.right_vib2;
    port3 = handles.left_vib1;
    port4 = handles.left_vib2;
    
    vib_stim_on = handles.vib_stim_on;
    vib_stim_off = handles.vib_stim_off;
    vib_level = handles.vib_level;

    switch vib_level
       case 1
           volt = 1.5;
       case 2
           volt = 3;
       case 3
           volt = 5;
    end
    
    if exist(filename)
        status = 'Same name file is exist';
        set(handles.status_display,'String',status);
        set(handles.status_display,'ForegroundColor',[1, 0, 0]);
        
    else
        cam.PixelFormat.Set(uc480.Defines.ColorMode.Mono8);
        cam.IO.Flash.SetAutoFreerunEnable(true); 
        cam.Acquisition.Capture;
        cam.Video.Start(filename);
        
        timestamp = tic;
        while toc(timestamp) <= 30
            
             cam.DirectRenderer.StealNextFrame(uc480.Defines.DeviceParameter.Wait);
             [err, I] = cam.Memory.CopyToArray(ID);

             I = reshape(uint8(I), Width, Height,[]).';
             % handles.Image = I;
             axes(handles.axes1);
             imshow(I);            
             
             if (toc(timestamp) >= vib_stim_on && toc(timestamp) <= vib_stim_off)
                 writePWMVoltage(ard, port1,volt);
                 writePWMVoltage(ard, port2,volt);
                 writePWMVoltage(ard, port3,volt);
                 writePWMVoltage(ard, port4,volt);
                 
             elseif (toc(timestamp)> vib_stim_off)
                 writePWMVoltage(ard, port1, 0);
                 writePWMVoltage(ard, port2, 0);
                 writePWMVoltage(ard, port3, 0);
                 writePWMVoltage(ard, port4, 0);
             end
             
        end

        cam.Video.Stop();
        cam.Acquisition.Stop();

        handles = record_save(handles);
    end
    
    guidata(hObject,handles);
end

% --- Executes on button press in record_all_in_one.
function record_all_in_one_Callback(hObject, eventdata, handles)
% hObject    handle to record_all_in_one (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end

function memo_Callback(hObject, eventdata, handles)
% hObject    handle to memo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of memo as text
%        str2double(get(hObject,'String')) returns contents of memo as a double
    handles.metadata = get(hObject,'String');
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function memo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to memo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function vib_level_Callback(hObject, eventdata, handles)
% hObject    handle to vib_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vib_level as text
%        str2double(get(hObject,'String')) returns contents of vib_level as a double
    

    vib_level = str2double(get(hObject,'String'));
    if vib_level < 1 || vib_level > 3
        status = 'Error: Put right vibration level between 1 to 5';
        set(handles.status_display,'String',status);
        set(handles.status_display,'ForegroundColor',[1, 0, 0]);
    end
    handles.vib_level = vib_level;
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function vib_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vib_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in vib_left.
function vib_left_Callback(hObject, eventdata, handles)
% hObject    handle to vib_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vib_left
    handles.vib_cond_left = get(hObject,'Value');
    %vib_level = str2double(get(handles.vib_level,'string'));
    vib_level = handles.vib_level;
    ard = handles.ard;
    port1 = handles.left_vib1;
    port2 = handles.left_vib2;
    
    if ~exist('ard','var')
        status = 'Please connect Arduino';
        set(handles.status_display,'String',status);
        
    end
    
    if handles.vib_cond_left == 1
       switch vib_level
           case 1
               volt = 1.5;
           case 2
               volt = 3;
           case 3
               volt = 5;
       end
       writePWMVoltage(ard, port1,volt);
       writePWMVoltage(ard, port2,volt);
    end
    
    if handles.vib_cond_left == 0
       
       writePWMVoltage(ard, port1, 0);
       writePWMVoltage(ard, port2, 0);
    end
    guidata(hObject, handles);
end

% --- Executes on button press in vib_right.
function vib_right_Callback(hObject, eventdata, handles)
% hObject    handle to vib_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vib_right
    handles.vib_cond_right = get(hObject,'Value');
    %vib_level = str2double(get(handles.vib_level,'string'));
    vib_level = handles.vib_level;
    ard = handles.ard;
    port3 = handles.right_vib1;
    port4 = handles.right_vib2;
    
    if ~exist('ard','var')
        status = 'Please connect Arduino';
        set(handles.status_display,'String',status);
        
    end
    
    if handles.vib_cond_right == 1
       switch vib_level
           case 1
               volt = 1.5;
           case 2
               volt = 3;
           case 3
               volt = 5;
       end
       writePWMVoltage(ard, port3,volt);
       writePWMVoltage(ard, port4,volt);
    end
    
    if handles.vib_cond_right == 0
       
       writePWMVoltage(ard, port3, 0);
       writePWMVoltage(ard, port4, 0);
    end
    guidata(hObject, handles);
end

% --- Executes on button press in vib_both.
function vib_both_Callback(hObject, eventdata, handles)
% hObject    handle to vib_both (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vib_both
    handles.vib_cond_both = get(hObject,'Value');
    %vib_level = str2double(get(handles.vib_level,'string'));
    vib_level = handles.vib_level;
    ard = handles.ard;
    port1 = handles.left_vib1;
    port2 = handles.left_vib2;
    port3 = handles.right_vib1;
    port4 = handles.right_vib2;
    
    
    
    if ~exist('ard','var')
        status = 'Please connect Arduino';
        set(handles.status_display,'String',status);
        
    end
    
    if handles.vib_cond_both == 1
       switch vib_level
           case 1
               volt = 1.5;
           case 2
               volt = 3;
           case 3
               volt = 5;
       end
       writePWMVoltage(ard, port1,volt);
       writePWMVoltage(ard, port2,volt);
       writePWMVoltage(ard, port3,volt);
       writePWMVoltage(ard, port4,volt);
    end
    
    if handles.vib_cond_both == 0
       
       writePWMVoltage(ard, port1, 0);
       writePWMVoltage(ard, port2, 0);
       writePWMVoltage(ard, port3, 0);
       writePWMVoltage(ard, port4, 0);
    end
    
    guidata(hObject, handles);
    
end

function status_display_Callback(hObject, eventdata, handles)
% hObject    handle to status_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of status_display as text
%        str2double(get(hObject,'String')) returns contents of status_display as a double

end

% --- Executes during object creation, after setting all properties.
function status_display_CreateFcn(hObject, eventdata, handles)
% hObject    handle to status_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end



function filename_Callback(hObject, eventdata, handles)
% hObject    handle to filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename as text
%        str2double(get(hObject,'String')) returns contents of filename as a double
    handles.filename = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in filename_control.
function filename_control_Callback(hObject, eventdata, handles)
% hObject    handle to filename_control (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filename_control
    handles.condition_control = get(hObject,'Value');
    guidata(hObject, handles);
end

% --- Executes on button press in filename_drug.
function filename_drug_Callback(hObject, eventdata, handles)
% hObject    handle to filename_drug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filename_drug
    handles.condition_drug = get(hObject,'Value');
    guidata(hObject, handles);
end

function filename_drugdose_Callback(hObject, eventdata, handles)
% hObject    handle to filename_drugdose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename_drugdose as text
%        str2double(get(hObject,'String')) returns contents of filename_drugdose as a double
    handles.drug_dose = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function filename_drugdose_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename_drugdose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function pixelclock_Callback(hObject, eventdata, handles)
% hObject    handle to pixelclock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pixelclock as text
%        str2double(get(hObject,'String')) returns contents of pixelclock as a double

    cam = handles.cam;
    handles.pixelclock = str2double(get(hObject,'String'));
    cam.Timing.PixelClock.Set(handles.pixelclock);
    [err, rate_min, rate_max, rate_inc] = cam.Timing.Framerate.GetFrameRateRange();
    fprintf('FrameRate min: %0.1f, max: %0.1f \n', rate_min, rate_max);
   
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function pixelclock_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixelclock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function filename_drugname_Callback(hObject, eventdata, handles)
% hObject    handle to filename_drugname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename_drugname as text
%        str2double(get(hObject,'String')) returns contents of filename_drugname as a double
    handles.drugname = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function filename_drugname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename_drugname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


%%
% [err, Min, Max, Inc] = cam.Timing.Exposure.Fine.GetRange();
% 
% [err, rate_min, rate_max, rate_inc] = cam.Timing.Framerate.GetFrameRateRange()
% [err, framerate] = cam.Timing.Framerate.GetDefault()
% 
% 
% [err, clock_min, clock_max, clock_inc] = cam.Timing.PixelClock.GetRange()
% [err, pixelclock] = cam.Timing.PixelClock.Get()
% pixelclock = 24
% 
% cam.Timing.PixelClock.Set(18)
% cam.Timing.PixelClock.Set(28)
% 
% 
% handles = setfield(handles, 'gain', 1);
% handles = setfield(handles, 'exposure', 10);
% handles = setfield(handles, 'framerate', 20);
% handles = setfield(handles, 'pixelclock', 28);
% 
% % Set stimulus timing
% handles = setfield(handles, 'light_stim_on', 20);
% handles = setfield(handles, 'light_stim_off', 40);
% handles = setfield(handles, 'vib_stim_on', 20);
% handles = setfield(handles, 'vib_stim_off', 40);
% 
% % Set stimulus magnitude
% handles = setfield(handles, 'light_level', 5);
% handles = setfield(handles, 'vib_level', 5);



function vid_num_Callback(hObject, eventdata, handles)
% hObject    handle to vid_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vid_num as text
%        str2double(get(hObject,'String')) returns contents of vid_num as a double
    
    vid_num = str2double(get(hObject,'String'));
    set(handles.vid_num, 'String',vid_num);
    
    guidata(hObject, handles);
end



% --- Executes during object creation, after setting all properties.
function vid_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vid_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
