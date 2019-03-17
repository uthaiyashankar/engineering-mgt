import React from 'react';
import Tabs, {Tab} from 'material-ui/Tabs';
import {MuiThemeProvider, createMuiTheme, withStyles } from 'material-ui/styles';
import MergedPR from './MergedPR';
import Milestones from './Milestones'

const styles = {
    MergedPR: {
        width: '95%',
        marginLeft:'auto',
        marginRight:'auto',
    }
};

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


class TabbedView extends React.Component {
    state = {
        value: 0,
    };

    handleChange = (event, value) => {
        this.setState({ value });
    };

    onSubmit(info) {
        alert(info.product);
    }

    render() {
        const { value } = this.state;
        return(
            <MuiThemeProvider theme={theme}>
                <div>
                    <Tabs value={value} onChange={this.handleChange}>
                        <Tab label="Pull Requests"/>
                        {/*{this.props.editable &&*/}
                            {/*<Tab label="Milestones"/>*/}
                        {/*}*/}
                    </Tabs>
                    <br/>
                    {value === 0 &&
                    <MergedPR editable={this.props.editable}/>
                    }
                    {/*{value === 1 && this.props.editable &&*/}
                    {/*<Milestones/>*/}
                    {/*}*/}
                </div>
            </MuiThemeProvider>
        );
    }
}

export default withStyles(styles)(TabbedView);