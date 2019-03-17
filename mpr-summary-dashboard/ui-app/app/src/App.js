import React from 'react';
import {MuiThemeProvider, createMuiTheme } from 'material-ui/styles';

import DefaultAppBar from './DefaultAppBar';
import TabbedView from "./TabbedView";
import axios from "axios/index";

var config = require('./config.json');

const hostUrl = config.url;


// const theme = createMuiTheme( {
//     palette: {
//         type:'dark',
//         background:'#000',
//     },
// });

function getTheme(theme) {
    return createMuiTheme({
        palette: {
            type: theme.paletteType,
            background: {
                default: theme.paletteType === 'light' ? '#fff' : '#000',
            },
        },
    });
}

const theme = getTheme({
    paletteType: 'light',
});


class App extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            editable:false,
            username:'',
        }
    }

    componentDidMount() {
        axios.get(hostUrl+'/access')
            .then(response => {
                if(response.hasOwnProperty("data")) {
                    console.log('response:');
                    console.log(response);
                    console.log(response.data);
                    this.setState({
                        editable:response.data["editable"],
                        username:response.data["username"],
                    });
                }
            })
            .catch(error => {
                this.setState({
                    editable:false
                });
            });


    }

    render() {
        return (
            <MuiThemeProvider theme={theme}>
                <div>
                    <DefaultAppBar username={this.state.username}/>
                    <TabbedView editable={this.state.editable}/>
                </div>
            </MuiThemeProvider>
        );
    }
}

export default App;