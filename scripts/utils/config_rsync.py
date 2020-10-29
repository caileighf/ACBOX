import json
import datetime
import os
import sys
from prompt_toolkit import prompt
from prompt_toolkit.shortcuts import yes_no_dialog

user_set_config_file = '{}/rsync_config.json'.format(os.getcwd())

def get_user_resp(user_prompt, default_val):
    resp = prompt('{} [or hit enter for default: {}]: '.format(user_prompt, default_val))
    if resp != '':
        return(resp)
    return(default_val)

def main(override):
    os.system('clear')

    if not override and os.path.exists(user_set_config_file):
        # use previous config
        with open(user_set_config_file, 'r') as f:
            user_data = json.load(f)
        user_set_config = user_data
    else:
        # make new config
        user_set_config = dict(
            REMOTE_USER="",
            REMOTE_IP="",
            REMOTE_DEST="",
            INCLUDE_GPS_DATA=True,
            INCLUDE_GPS_LOGS=True,
            CLEAN=False,
            PARALLEL=False,
            )

    print('Configure RSYNC Remote Parameters:')
    print('----------------------------------')
    user_set_config['REMOTE_USER'] = get_user_resp(user_prompt='Enter the remote user', default_val=user_set_config['REMOTE_USER'])
    print('Remote User: {}\n'.format(user_set_config['REMOTE_USER']))

    user_set_config['REMOTE_IP'] = get_user_resp(user_prompt='Enter the remote IP address', default_val=user_set_config['REMOTE_IP'])
    print('Remote IP: {}\n'.format(user_set_config['REMOTE_IP']))

    user_set_config['REMOTE_DEST'] = get_user_resp(user_prompt='Enter the remote destination', default_val=user_set_config['REMOTE_DEST'])
    print('Remote Destination: {}\n'.format(user_set_config['REMOTE_DEST']))

    user_set_config['INCLUDE_GPS_DATA'] = yes_no_dialog(title='GPS Data', text='Include GPS data?').run()
    user_set_config['INCLUDE_GPS_LOGS'] = yes_no_dialog(title='GPS Logs', text='Include GPS logs?').run()

    user_set_config['CLEAN'] = yes_no_dialog(title='Clean source', text='Remove source data after successful transfer?').run()
    user_set_config['PARALLEL'] = yes_no_dialog(title='Run in parallel', text='Default to parallel mode? (If running run another script enter NO)').run()

    formatted_config = ['{} = {}'.format(key, value) for key, value in user_set_config.items()]
    formatted_config = '\n'.join(formatted_config)

    if yes_no_dialog(title='Save Config', text='Save the following config? \n\n{}\n'.format(formatted_config)).run():
        # write to config file
        with open(user_set_config_file, 'w') as f:
            json.dump(user_set_config, f, indent=4, sort_keys=True)
    else:
        print('Config NOT saved')

if __name__ == '__main__':
    if len(sys.argv) >= 2:
        if sys.argv[1] == '--override':
            override = True
    else:
        override = False
    try:
        main(override)
    except KeyboardInterrupt:
        pass
    except KeyError:
        import traceback
        traceback.print_exc()
        print('Problem with config file! Run with --override to reset to defaults')
    finally:
        print('\n\tEnding...\n')