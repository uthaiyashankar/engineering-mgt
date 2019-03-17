import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from 'material-ui/styles';
import AppBar from 'material-ui/AppBar';
import Toolbar from 'material-ui/Toolbar';
import Typography from 'material-ui/Typography';
import {MuiThemeProvider, createMuiTheme } from 'material-ui/styles';
import Button from 'material-ui/Button';

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
    paletteType: 'dark',
});

const styles = {
    root: {
        flexGrow: 1,
    },
    flex: {
        flex: 1,
    },
    logo: {
        // width: '80px',
        paddingRight: '50px',
        // paddingLeft: '20px',
        // paddingBottom: '5px',
        // verticalAlign: 'bottom',
    },
    title: {
        color:'white',
    },
    login: {
        position:'absolute',
        right:'0px',
        width:'250px',
        padding:'20px',
        textAlign:'right',
    },
};

function DefaultAppBar(props) {
    const { classes } = props;
    return (
        <MuiThemeProvider theme={theme}>
            <div className={classes.root}>
                <AppBar position="static" color="default">
                    <Toolbar>
                        <Typography align="left" color="inherit">
                            <img style={styles.logo}
                                 src={process.env.PUBLIC_URL + '/assets/images/wso2-logo.svg'}
                                 alt={'WSO2'}/>
                        </Typography>
                        <Typography variant="title" color="inherit" className={classes.flex}>
                            MPR Dashboard
                        </Typography>
                        {props.username &&
                            <div style={styles.login}>
                                <b>{props.username}</b>
                            </div>
                        }
                    </Toolbar>
                </AppBar>
            </div>
        </MuiThemeProvider>
    );
}

DefaultAppBar.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(DefaultAppBar);