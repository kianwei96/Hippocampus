function vmhplfp(varargin)
    % get channel string
    [p1, chstr] = nptFileParts(pwd);
    % get array string
    [p2, arrstr] = nptFileParts(p1);
    % get session string
    [p3, sesstr] = nptFileParts(p2);
    % get day string
    [p4, daystr] = nptFileParts(p3);
    
    % to read Args
    load([p2,'/rsData']);

	vh = vmhighpass('auto','SaveLevels',2,varargin{:});
	vl = vmlfp('auto','SaveLevels',2,varargin{:});

	if(~Args.SkipSort)
		display('Launching spike sorting ...')
		% check to see if we should sort this channel
		if(isempty(dir('skipsort.txt')))

            % make channel direcory on HPC, copy to HPC, cd to channel directory, and then run hmmsort
			display('Creating channel directory ...')
            cmdRedirect = '';
            cmdSCP = '';
            if ~Args.UseHPC % swap between the HPC and HTCondor
                cmdRedirect = 'ssh eleys@atlas7 ';
                syscmd = [cmdRedirect, 'cd ~/hpctmp/Data/' daystr '/' sesstr '/' arrstr '; mkdir ' chstr];
                display(syscmd)
                system(syscmd);
                display('Transferring rplhighpass file ...')
                syscmd = ['scp rplhighpass.mat eleys@atlas7:~/hpctmp/Data/' daystr '/' sesstr '/' arrstr '/' chstr];
                display(syscmd)
                rval=1;
                while(rval~=0)
                    rval=system(syscmd);
                end
            end
			display('Running spike sorting ...')
			syscmd = [cmdRedirect, 'cd ~/hpctmp/Data/' daystr '/' sesstr '/' arrstr '/' chstr '; ~/hmmsort/hmmsort_pbs.py ~/hmmsort'];
			display(syscmd)
			system(syscmd);
		end  % if(isempty(dir('skipsort.txt')))
	end  % if(Args.SkipSort)
	